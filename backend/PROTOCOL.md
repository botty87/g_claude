# Protocollo sidecar ↔ client (v1)

Unico protocollo di messaggi tra Clyde (client) e il sidecar Node (Agent SDK).
Transport corrente: **stdio NDJSON** (una riga JSON per messaggio). Astratto dietro
`SidecarTransport` lato Dart → sostituibile con WebSocket per il remoto senza cambiare i payload.

- Ogni messaggio è un oggetto JSON su una riga (`\n`-terminated), UTF-8.
- `sid` = session id assegnato dal client (= `workspaceId` in Clyde). Identifica la sessione.
- I round-trip (permesso / domanda / piano) si correlano via `toolUseID` (fornito dall'SDK).
- Direzioni: **REQ** = client→sidecar, **EVT** = sidecar→client.

## REQ — client → sidecar

| `t` | Campi | Significato |
|---|---|---|
| `start` | `sid, cwd, prompt, mode, model?, effort?, thinking?, resume?, images?[], disabledMcp?[]` | Crea la sessione `sid` e avvia il primo turno. `mode` ∈ default/acceptEdits/bypassPermissions/plan. `resume` = session id Claude da riprendere. `images` = path file locali. |
| `input` | `sid, text, images?[]` | Invia un prompt successivo nella stessa sessione (streaming-input, multi-turn). |
| `permission` | `sid, toolUseID, decision:"allow"\|"deny", updatedInput?, message?, remember?` | Risposta a `permissionRequest`. `remember:true` → auto-allow successivi nella sessione. |
| `answerQuestion` | `sid, toolUseID, questions, answers` | Risposta a `askUserQuestion`. `answers` = mappa `{[questionText]: label}` (multi: label join `", "`). |
| `plan` | `sid, toolUseID, decision:"approve"\|"reject", mode?, message?` | Risposta a `planProposed`. approve → il sidecar fa `setPermissionMode(mode ?? "acceptEdits")` poi allow. reject → deny graceful (no abort), Claude resta in sessione. |
| `setMode` | `sid, mode` | Cambia permission mode a runtime (`setPermissionMode`). |
| `stop` | `sid` | `interrupt()` della sessione. |
| `close` | `sid` | Chiude e dealloca la sessione. |
| `mcpToggle` | `sid, serverName, enabled` | (TODO Fase ≥2) abilita/disabilita MCP server. |
| `mcpAuth` | `sid, serverName` | (TODO Fase ≥2) avvia OAuth MCP, ritorna authUrl via EVT `mcpAuthUrl`. |

## EVT — sidecar → client

Eventi di dominio (mappano 1:1 su `ClaudeEvent` lato Dart). Tutti includono `sid`.

| `t` | Campi | ClaudeEvent |
|---|---|---|
| `sessionInit` | `sessionId, model, tools[], skills[], slashCommands[], plugins[{name,path,source?}], apiKeySource` | `sessionInit` |
| `textChunk` | `text` | `textChunk` |
| `toolCall` | `toolName, toolId, index` | `toolCall` |
| `toolCallUpdate` | `toolId, partialInput` | `toolCallUpdate` |
| `toolCallComplete` | `index, toolId?, input?` | `toolCallComplete` |
| `toolResult` | `toolUseId, content, isError` | `toolResult` |
| `assistantMessage` | `text` | `assistantMessage` |
| `usageUpdate` | `inputTokens?, cacheReadTokens?, cacheCreationTokens?, outputTokens?` | `usageUpdate` |
| `taskComplete` | `result?, costUsd?, durationMs?, numTurns?` | `taskComplete` |
| `errorEvent` | `message` | `errorEvent` |
| `rateLimit` | `status, resetsAt?` | `rateLimit` |
| `sessionDead` | `exitCode?, stderrTail[]` | `sessionDead` |
| `permissionRequest` | `toolUseID, toolName, toolInput` | `permissionRequest` (solo caso "ask") |
| `askUserQuestion` | `toolUseID, questions[{question,header,multiSelect,options[{label,description}]}]` | `askUserQuestion` |
| `planProposed` | `toolUseID, plan, planFilePath?` | `planProposed` (NUOVO) |

Eventi di trasporto/sistema (non sono `ClaudeEvent`):

| `t` | Campi | Significato |
|---|---|---|
| `ready` | `sdk, cli?` | Sidecar pronto, versioni. Primo messaggio emesso al boot. |
| `ack` | `sid, ref` | (opz.) conferma ricezione di una REQ. |
| `fatal` | `message, sid?` | Errore non recuperabile (es. iteratore SDK in throw). |

## Note semantiche
- **Permessi**: il sidecar replica la logica di Clyde (`decisionFor(mode, toolName, allowAlways)`):
  plan→ read-only `allow` altrimenti `deny`; acceptEdits/bypass→ `allow`; default→ `(allowAlways || readOnly) ? allow : ask`.
  Solo il caso `ask` produce un `permissionRequest` e attende la REQ `permission`.
- **Read-only tools** (auto-allow): Read, Glob, Grep, BashOutput, KillShell, NotebookRead, TodoWrite, WebFetch, WebSearch, ExitPlanMode, ListMcpResourcesTool, ReadMcpResourceTool.
- **Piano**: `ExitPlanMode` non passa dal flusso permessi normale; emette `planProposed`. approve commuta il mode e fa `allow`; reject fa `deny {interrupt:false}` (graceful: Claude acknowledged e aspetta, niente eccezione).
- **Auth**: nessuna `ANTHROPIC_API_KEY`; usa OAuth della CLI. `apiKeySource` in `sessionInit` lo conferma.
- **Multi-sessione**: un solo processo sidecar, `Map<sid, Session>`. Ogni sessione ha la sua `query()` in streaming-input mode.
