# Piano migrazione Clyde → Agent SDK (sidecar locale, protocollo unico)

> Stato: **Fase 0→4 FATTE e verificate** (+ controlli modi/thinking/1M/model, MCP fast-list+toggle). Decisioni: long-lived multi-sessione · stdio dietro interfaccia · `spike-agent-sdk`→`backend/`. **Uso interno: niente Developer ID/notarization** (deciso).
> Prossimo: Fase 5 (test/cleanup/docs) + rifiniture. Branch `feature/claude-sdk`. Remoto/WS/Tailscale = fuori scope.
>
> **Fase 4 (packaging)**: sidecar bundlato in un singolo `.cjs` self-contained via esbuild (banner+define per `import.meta.url` in CJS), embedded in `Clyde.app/Contents/Resources`. Transport: dev → `npx tsx`; release (`kReleaseMode`) → `node <Resources>/clyde-sidecar.cjs` con `node` risolto (path assoluti + `zsh -ilc`, gestisce PATH minimo da Finder). `just build-sidecar` + `build-mac` (bundle→build→copia→strip font). Niente SEA (il `node` di sistema è shared-lib) e niente binario da firmare (il `.cjs` è dati; l'app la firma Flutter). Verificato: bundle gira con env spogliato (sim Finder), app release parte, e l'artefatto spedito guida un round-trip completo con `CLAUDE_CLI_PATH` settato (come fa il transport). **Nota**: il bundle isolato richiede sempre `pathToClaudeCodeExecutable` (via `CLAUDE_CLI_PATH`), che il transport passa sempre. Manuale non automatizzabile (no marionette in release): 30s di click-through nella GUI release.
>
> **Verifica Fase 2+3**: `dart analyze` pulito · 78 test claude verdi · DI corretto (Shelf/process-datasource rimossi, sidecar registrato) · **integration test live (Dart↔sidecar→CLI)**: lifecycle (start→taskComplete→sessionDead, stream completa) ✓ e plan round-trip (planProposed→approve→scrive calc.js in cwd) ✓.
> **Bug trovato+fixato in verifica**: il sidecar non chiudeva la sessione dopo `taskComplete` (streaming-input resta viva) → lo stream Dart non si completava. Aggiunto auto-close one-shot (keepAlive=false default) in `backend/src/session.ts`.
> **Build GUI risolto**: pinnato Flutter **3.41.9** in `.fvmrc` (Dart 3.11.5, compatibile con `re_editor 0.8.0`; 3.44.4 rompe per `TextInputClient.onFocusReceived`). App compila e gira. Alternativa futura: bump `re_editor` per tornare su stable.
> **Verifica GUI live (marionette)**: aperto workspace di test, plan mode, prompt → **card "Piano proposto" si renderizza**, "Approva" → sidecar `setPermissionMode(acceptEdits)` → Claude scrive il file in cwd, explorer si aggiorna via watcher, stato torna "Pronto". Provato due volte (hello.txt, bye.txt). Richiesto bump `marionette_flutter` 0.5.0→0.6.0 per allineare al server MCP.
> **2° bug trovato+fixato in verifica GUI**: `answerPlan` approve ritornava `{behavior:'allow'}` senza `updatedInput` → l'SDK (Zod) lo rifiutava (`ExitPlanMode err=true`, non-fatale ma "1 errori" nella UI). Fix in `session.ts`: backfill centralizzato di `updatedInput` (input originale) su ogni `allow`. Confermato: 2° giro GUI = "0 errori".
>
> **Validato (Fase 1)**: i 3 round-trip funzionano attraverso il protocollo del sidecar — AskUserQuestion (prosegue con scelta), ExitPlanMode approve (setPermissionMode→scrive in cwd), reject graceful (no scrittura, ri-propone, turno completa). `apiKeySource=none` (abbonamento). Contenimento `cwd` ok con path relativi. Note: in streaming-input mode `taskComplete`=fine TURNO (sessione resta viva); Claude si ancora alla git-root che contiene cwd (per Clyde ok: workspace=cartella).
> Obiettivo: l'utente avvia Clyde e basta; sotto gira un sidecar Node con l'Agent SDK che parla
> con la CLI `claude` via OAuth abbonamento. Sblocca i round-trip Plan Mode + AskUserQuestion.

## Perché (de-rischiato dallo spike)

Clyde oggi è già un mini-SDK fatto a mano: pilota `claude -p --input/output-format stream-json
--include-partial-messages`, scrive user message su stdin, ha un canale `control_request/response`
e i permessi via hook `PreToolUse`→curl→Shelf server. **Il limite**: l'hook può solo `allow/deny/ask`,
**non può ritornare `updatedInput`** → AskUserQuestion disabilitato (`askUserQuestionInteractiveEnabled=false`,
issue claude-code #16712) e ExitPlanMode è solo simulato (auto-allow + system-prompt hint). L'SDK,
via `canUseTool`, ritorna `updatedInput` e mette in pausa la sessione: spike `spike-agent-sdk/` lo prova.

## Architettura target

```
Clyde (Flutter)
  └─ SidecarClientDataSource  ──stdio NDJSON (protocollo unico)──▶  sidecar Node (Agent SDK)
        (spawn + lifecycle)                                              └─ query() per sessione ──▶ CLI claude (OAuth)
```

- **Un sidecar long-lived**, gestito da Clyde (spawn all'avvio app, kill alla chiusura, restart su crash),
  invisibile all'utente. Hosta **N sessioni** keyed per `workspaceId` (= il "session manager multi-istanza").
- **Transport**: stdio NDJSON ora, dietro un'interfaccia `SidecarTransport` → si sostituisce con WS per il remoto senza toccare la logica.
- **Un solo protocollo di messaggi** (request client→sidecar, event sidecar→client). Vedi Fase 0.
- **`ClaudeEvent` resta il contratto interno**: il sidecar emette eventi che vi mappano 1:1. Il cubit cambia pochissimo.

### Cosa si elimina
- `data/datasources/permission_server.dart` (Shelf) → sostituito da evento `permissionRequest` sul protocollo.
- `data/datasources/claude_settings_writer.dart` (hook PreToolUse/curl) → non serve più, `canUseTool` lo rimpiazza.
- Logica `_decisionFor`/`_resolvePermission` lato cubit → spostata nel sidecar (single source of truth dei permessi).

### Cosa resta / cambia poco
- `ClaudeEvent` (+ nuova variante `planProposed`), `ClaudeMessage` (+ card piano), usage, queued prompt.
- `ClaudeSessionsCubit`: flip `askUserQuestionInteractiveEnabled=true`; rendering card piano; risposta permesso/domanda/piano via nuovi metodi repo; rimozione resolver server-side.
- `claude_binary_resolver.dart` → ri-usato per risolvere binario sidecar + path CLI `claude` (passato all'SDK via `pathToClaudeCodeExecutable`).

---

## FASE 0 — Spec protocollo unico  (deliverable: `PROTOCOL.md`)

Definire il contratto stdio NDJSON. Bozza:

**Client → Sidecar (request)**
- [ ] `{t:"start", sid, cwd, prompt, mode, model?, effort?, thinking?, resume?, images?[], disabledMcp?[]}` — apre/continua una sessione
- [ ] `{t:"input", sid, text, images?[]}` — prompt successivo nella stessa sessione (streaming-input multi-turn)
- [ ] `{t:"permission", sid, toolUseID, decision:"allow"|"deny", updatedInput?, message?}`
- [ ] `{t:"answerQuestion", sid, toolUseID, questions, answers}`
- [ ] `{t:"plan", sid, toolUseID, decision:"approve"|"reject", message?}`  (approve → sidecar `setPermissionMode`)
- [ ] `{t:"setMode", sid, mode}` · `{t:"stop", sid}` · `{t:"mcpToggle", sid, serverName, enabled}` · `{t:"mcpAuth", sid, serverName}`

**Sidecar → Client (event)** — mappano su `ClaudeEvent`
- [ ] `sessionInit, textChunk, toolCall, toolCallUpdate, toolCallComplete, toolResult, assistantMessage, taskComplete, errorEvent, rateLimit, sessionDead, usageUpdate` (tutti con `sid`)
- [ ] `permissionRequest{sid, toolUseID, toolName, toolInput}` (solo caso "ask")
- [ ] `askUserQuestion{sid, toolUseID, questions}`
- [ ] `planProposed{sid, toolUseID, plan, planFilePath}`  ← nuovo
- [ ] envelope per error/ready/heartbeat del sidecar stesso

Chiave di correlazione round-trip = `toolUseID` (fornito dall'SDK, confermato dallo spike).

---

## FASE 1 — Sidecar Node/TS  (deliverable: evoluzione di `spike-agent-sdk/` → `backend/`)

- [ ] Progetto TS: `query()` in **streaming-input mode** (`AsyncIterable<SDKUserMessage>`) per multi-turn + `setPermissionMode/interrupt`.
- [ ] **Session manager**: `Map<sid, {query, inputQueue, ...}>`; `start` crea, `input` accoda, `stop` → `interrupt()`.
- [ ] **`canUseTool` unico** che instrada:
  - `AskUserQuestion` → emette `askUserQuestion`, attende `answerQuestion`, ritorna `{allow, updatedInput:{questions,answers}}`.
  - `ExitPlanMode` → emette `planProposed`, attende `plan`: approve → `setPermissionMode(<mode non-plan della sessione>)` + `{allow}`; reject → `{deny, message, interrupt:false}` (graceful, no abort).
  - altri tool → replica `_decisionFor(mode, toolName)`: plan→read-only allow/else deny; acceptEdits/bypass→allow; default→(allowAlways||readOnly)? allow : emette `permissionRequest` e attende.
- [ ] Mappatura `SDKMessage` → eventi protocollo (incl. `SDKPartialAssistantMessage`→textChunk, `SDKRateLimitEvent`→rateLimit, `result`→taskComplete/errorEvent, usage→usageUpdate).
- [ ] Auth abbonamento (nessuna API key) + `pathToClaudeCodeExecutable`. MCP toggle/auth via opzioni SDK.
- [ ] Pin versioni SDK↔CLI. Gestione `error_during_execution` + try/catch sull'iteratore.
- [ ] **Test headless**: script client finto (riusa harness spike) che pilota il protocollo da terminale e valida i 3 round-trip.

---

## FASE 2 — Dart: SidecarClientDataSource + rewiring data layer

- [ ] `SidecarTransport` (interface) + `StdioSidecarTransport` (spawn process, NDJSON in/out, lifecycle, health/ready, restart).
- [ ] `SidecarClientDataSource`: parsing eventi protocollo → `ClaudeEvent`; invio request; multiplexing per `sid`/workspaceId.
- [ ] `ClaudeRepositoryImpl` rifatto sopra il datasource; aggiornare interface `ClaudeRepository` (vedi sotto).
- [ ] Cambi `ClaudeRepository`: `respondPermission({toolUseID, decision, updatedInput?})`, `answerQuestion({toolUseID, questions, answers})`, `answerPlan({toolUseID, approve, message?})`, `setMode`, `sendInput` per multi-turn. Mantieni `startRun/stop/toggleMcp/authMcp`.
- [ ] **Eliminare** `permission_server.dart`, `claude_settings_writer.dart`; aggiornare DI, rimuovere riferimenti Shelf.
- [ ] `claude_binary_resolver` → risolve sidecar binary + CLI `claude`.
- [ ] App compila e gira in locale puntando al sidecar (dev: `node`/`tsx`; prod: Fase 4).

---

## FASE 3 — UI: riabilitare i round-trip

- [ ] `claude_event.dart`: aggiungere variante `planProposed`; eventuale `toolUseID` su `permissionRequest`. Codegen freezed.
- [ ] `claude_message.dart`: variante/card piano (riusa pattern `ask_user_question_card`); rigenerare.
- [ ] Flip `askUserQuestionInteractiveEnabled = true` (ora il round-trip esiste).
- [ ] Cubit: rendering `planProposed` → card approve/reject; `answerPlan`; permesso ora supporta `updatedInput`; rimuovere resolver server-side (delegato al sidecar).
- [ ] Verifica end-to-end nell'app reale (marionette): plan approve→edita, reject→si ferma; AskUserQuestion→prosegue con scelta.

---

## FASE 4 — Packaging trasparente (macOS-first)

- [ ] Compilare il sidecar in **binario self-contained** (Node SEA o `bun build --compile`) → niente Node da installare.
- [ ] Embed nel bundle `.app` (Resources); lifecycle gestito da Clyde (start all'avvio, kill on quit, restart su crash, health check prima di connettere).
- [ ] CLI `claude`: risolvere path (assumere installata o bundlare); passare via `pathToClaudeCodeExecutable`.
- [ ] **Signing + notarization** del binario helper dentro il bundle (Gatekeeper). Integrare in `just build-mac`.
- [ ] OAuth: usa `~/.claude/.credentials.json` dell'utente (locale, già presente).

---

## FASE 5 — Test, cleanup, docs

- [ ] Unit test puri: mappatura protocollo↔`ClaudeEvent`, escape/parse (fixture reali).
- [ ] `bloc_test` cubit: transizioni con question/plan riabilitati, routing risposta per `toolUseID`.
- [ ] Test sidecar protocollo (TS).
- [ ] Rimuovere codice morto (Shelf, settings writer, flag). Aggiornare `CLAUDE.md` (sezione claude) + README.

---

## Rischi residui (rinviati alla fase remota, non bloccano il locale)
- Rate-limit con sessioni concorrenti reali (non provato).
- Longevità/refresh OAuth su VPS headless.
- Volume prompt permessi (Bash post-piano ri-bussa) → valutare allow-rules / bypass selettivo.

## Decisioni da confermare prima di applicare
1. **Topologia sidecar**: un sidecar long-lived multi-sessione (consigliato, no-throwaway) vs un processo-per-run (cambio minimo). → consiglio: long-lived.
2. **Transport ora**: stdio dietro interfaccia (consigliato) vs localhost-WS subito.
3. **Posizione codice sidecar**: evolvere `spike-agent-sdk/` → `backend/` nel repo.

## Review (compilare a fine lavoro)
- _da fare_
