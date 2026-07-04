# MCP Hardening — piano (branch feature/mcp-hardening)

Ground truth verificata empiricamente (probe sidecar/SDK + `claude mcp list` + estrazione binario CLI).

## Task 2 — naming toggle disabledMcp → prefisso tool (86cah46y7)
**Bug confermato.** Backend `session.ts:117` fa `mcp__${n}__*` col nome RAW. Ma la CLI
namespacea i tool con `Vl(name)`:
```js
Vl(e){let t=e.replace(/[^a-zA-Z0-9_-]/g,"_");
  if(e.startsWith("claude.ai "))t=t.replace(/_+/g,"_").replace(/^_|_$/g,"");return t}
```
- "claude.ai Slack" → `claude_ai_Slack` (oggi backend genera `mcp__claude.ai Slack__*` = ROTTO)
- "clickup-extras" → `clickup-extras` (ok), "plugin:firebase:firebase" → `plugin_firebase_firebase`
- Dart manda `server.name` RAW (verificato: `McpServer.name` non pulito). Fix = applicare `Vl` nel backend.

**Fix:** `backend/src/session.ts` — helper `sanitizeMcpToolPrefix(name)` (replica `Vl`), usato in `disallowedTools`. Test unit backend (node --test).

## Task 2-bis — status glyph (BONUS, stesso file, da confermare con utente)
`mcp_list_datasource.dart:55` mappa `'✓ Connected'` (U+2713) ma la CLI emette `✔` (U+2714)
→ tutti i connected diventano `unknown`. Fix robusto: match su substring.

## Task 1 — OAuth MCP auth (86cah46yb, High)
`query.mcpAuthenticate(serverName, redirectUri)` → `{authUrl, requiresUserAction:true, callbackExpected:false}`.
Connettori claude.ai brokerati server-side: apri authUrl, claude.ai completa, auth account-wide.
**Crux:** serve Query streaming viva → **sessione effimera keepAlive dedicata all'auth**.
- `protocol.ts`: Req `{t:'mcpAuth', sid, serverName}`; EVT `{t:'mcpAuthUrl',...}` + `mcpAuthError`.
- `session.ts`: query keepAlive effimera → mcpAuthenticate → emit authUrl → close (timeout).
- Datasource/repo: implementa `authenticateMcpServer`. Cubit: no run richiesto, apre browser, refresh.

## Task 3 — conteggio "N attivi" reattivo (86caj6nz4, Low)
Cache privata senza `emit` → totale non reattivo. Fix: `mcpServers` in `ClaudeSessionsState` emesso; overlay via `context.select`.

## Task 4 — seam @visibleForTesting merge sessionInit (86cah46yz, Low, test)
`_mergeMcpServersFromSessionInit` → `@visibleForTesting`; asserisce su `cubit.state.mcpServers`.

## Verifica
`just analyze` · `just format-check` · `fvm flutter test` · `npm test` (backend). Diff+test all'utente prima di commit.
