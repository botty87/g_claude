# ClickUp 86cahc8ez — Fase Run-concorrenti — motore N-run (Flutter + sidecar)

Obiettivo: abilitare N run Claude concorrenti — tra workspace diversi E tra tab dello stesso
workspace — sostituendo lo slot singolo globale in `ClaudeSessionsCubit` con una mappa di run
per `(workspaceId, tabId)`, ciascuno con un `sid` distinto lato sidecar.

## Scoperta chiave (evidenza da esplorazione, non rivalutare)
- Il sidecar Node (`backend/`) è **già multi-sessione** (`SessionManager.sessions: Map<sid,
  Session>`, `session.ts:324-357`) e **non richiede alcuna modifica**.
- `cwd` viaggia indipendente da `sid` in `Session.start()` (`session.ts:110-142` — `cwd: req.cwd`
  passato a `query()` a prescindere dal valore di `sid`, usato solo come chiave del Map e per
  taggare gli eventi). Cambiare lo schema di `sid` è quindi **puramente client-side**.
- Oggi `sid == cwd == workspaceId` (`sidecar_client_datasource.dart:38`) → due tab dello stesso
  workspace che avviano un run in parallelo si ucciderebbero a vicenda lato sidecar
  (`session.ts:330-331`, `existing.close()` su `sid` duplicato). Fix: `sid =
  '$workspaceId::$tabId'`, `cwd` resta `workspaceId` (history JSONL + risoluzione MCP dipendono
  da `cwd`, non da `sid`).

## Task — Data/domain layer (plumbing esplicito di `sid`)
- [x] **Step 1** `sidecar_client_datasource.dart:25-38` — `startRun` prende `required String sid`
      (rimuovi `final sid = cwd;` a riga 38); `cwd` resta invariato.
- [x] **Step 2** `claude_repository.dart:12-22` + `claude_repository_impl.dart:22-44` — aggiungi
      `required String sid` a interfaccia e impl, forward a `_datasource.startRun`. Correggi i
      doc-comment obsoleti (`sid = cwd = workspaceId`).
- [x] **Step 3** `send_prompt.dart:13-38,47-58` — `SendPromptParams` aggiunge `required this.sid`
      (+ `props`), `SendPrompt.call` lo forwarda.

## Task — Cubit (refactor centrale)
- [x] **Step 4** `claude_sessions_cubit.dart` — introduci `_RunController` (workspaceId, tabId,
      sid, sub, chunkFlushTimer, lastFlushAt, streamingText) + `Map<String, _RunController>
      _runs` e `_sidFor(wid, tabId)`. Rimuovi i 6 campi scalari (righe 75-81).
- [x] **Step 5** `sendPrompt` (930-1082) — guardia per-tab via `_runs.containsKey(_sidFor(...))`;
      registra `_RunController` in `_runs`; `SendPromptParams(sid: ...)`; `onDone` guard su
      `_runs.containsKey(sid)` (doppio-finish).
- [x] **Step 6** Handler eventi (1084-1340) — `_onEvent`/`_handleEvent` e tutti gli helper
      (`_toolNameFor`, `_streamingMessageIdFor`, `_flushStreamingChunks`, `_ensureStreamingMessage`,
      `_replaceStreamingMessage`, `_appendMessage`, `_completeToolMessage`, `_attachToolResult`)
      leggono da `ctl` (workspaceId/tabId/streamingText/timer), non da scalari globali. Elimina
      `_runTab`/`_emitRunTab` (usa `_emitTab` con id espliciti).
- [x] **Step 7** `_finishRun`/`_cleanupRun`/drain (1367-1415, 898-928) — prendono `ctl`; sostituisci
      `_drainNextQueued` (FIFO globale) con `_drainTab(wid, tabId)` (solo quel tab, NO fallback
      cross-tab).
- [x] **Step 8** Migrazione esaustiva `sid:`/guardie in: `_onWorkspacesChanged` (271),
      `clearConversation` (446-449), `resumeSession` (808-811), `close` (1534-1541),
      `setPermissionMode` (424-426), `answerAskUserQuestion` (747), `answerPlan` (776),
      `answerPermission` (799), `closeTab` (512-514). **Grep finale**: zero occorrenze di
      `_runningWorkspaceId`/`_runningTabId` nel file.
- [x] **Step 9** `stopRun` (856-864) → `stopRun(String workspaceId, {String? tabId})`, risolve
      `tabId` sull'active tab se omesso, stoppa solo quel `sid`.
- [x] **Step 10** `compactSession` (573-719) — stesso pattern: guardia per-tab, registra
      `_RunController`, `SendPromptParams(sid:)`, cleanup + `_drainTab` sul proprio tab (NON sugli
      scalari globali).

## Task — UI
- [x] **Step 11** `claude_input_bar.dart:291,304,433` — `stopRun()` → `stopRun(workspaceId)`
      (widget ha già `workspaceId` in scope). `[parallel-ok con Step 13]`

## Task — Mechanics & test
- [x] **Step 12** `just analyze` pulito (no build_runner/l10n regen richiesti).
- [x] **Step 13a** Fix compilazione test (aggiungi `sid:` a `SendPromptParams`/`startRun` in
      `claude_sessions_cubit_tabs_test.dart`, `claude_sessions_cubit_events_test.dart`,
      `sidecar_client_datasource_test.dart`, `integration/sidecar_bridge_test.dart`). Riscrivi il
      test obsoleto single-run (`claude_sessions_cubit_tabs_test.dart:199-223`) al nuovo contratto
      (sibling tab gira concorrente, non si accoda).
- [ ] **Step 13b** (altro agente) Nuovi test: run indipendenti tra workspace, run indipendenti tra
      tab stesso workspace (sid distinti), coda FIFO per singolo tab, `stopRun` mirato non tocca gli
      altri run.

## Verifica end-to-end
- [ ] `just analyze` + `just test` verdi.
- [ ] `claude_sessions_cubit_events_test.dart` (single-run) passa invariato — prova che il
      refactor del routing non ha rotto la semantica single-run.
- [ ] Smoke manuale (`just run`): due workspace concorrenti; due tab stesso workspace concorrenti
      (nessuno muore); coda su stesso tab busy; `stopRun` mirato lascia gli altri run attivi.

## Rischi
1. Migrazione esaustiva Step 8 — un sito mancato invia a un `sid` sbagliato senza errore visibile.
2. Guardia doppio-finish in Step 5 — senza, `_finishRun`/`_drainTab` possono scattare due volte.
3. `compactSession` (Step 10) — percorso separato, facile da migrare a metà.

## Fuori scope (tracciato separatamente)
- Gap `multiSelect` in `AskUserQuestionCard` (UI forza single-select anche quando l'SDK chiede
  multi-scelta) — task ClickUp separato, non in questo giro.
- Piccola richiesta UX utente: interazione da tastiera (Tab/Invio) + feedback cursore hover/click
  su `ask_user_question_card.dart` — piccola fix separata (1 file), non parte del motore N-run.

## Review
(da compilare a fine implementazione)
