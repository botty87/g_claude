# Lessons

## Eliminare un useState mirror: migrare anche i callers

**Pattern**: quando si rimuove un `useState<T>` che mirroreggiava un campo del cubit, sostituire con `context.select` non basta. Tutti i callers che leggevano la variabile locale dentro callback long-lived (`onPressed`, `onDragDone`, listener registrati in `useEffect`) vanno migrati a leggere live dal cubit (`cubit.state.sessions[id]?.field`).

**Perché**: la variabile da `context.select` cattura uno snapshot al momento del build. Tra build e firing del callback il cubit può aver emesso nuovo state (es. drag-drop pane modifica attachments mentre input bar non ha ancora rebuiltato). Il callback ricostruisce `next` da snapshot stale → sovrascrittura silente del state cubit.

**Sintomo tipico**: race in cui un'azione utente "annulla" una modifica appena avvenuta (drag-drop riappare dopo remove, chip riappare dopo backspace, ecc).

**Riferimento**: fix iterativi su `claude_input_bar.dart` (`2654c13` rimosse `attachmentList` useState; `188d3e9` patchò solo `persistDraft` ma non i callers; `fix/input-bar-stale-state` chiuse il loop migrando anche `selectedChips` e leggendo live in tutti i callbacks).

## Test infra: SharedPreferences sotto flutter_test va sempre mockato

**Pattern**: `EasyLocalization.ensureInitialized()` (e qualunque altro consumer di `SharedPreferences.getInstance()`) richiede `SharedPreferences.setMockInitialValues({})` prima dell'init nei widget test. Senza questo:
- `MissingPluginException` viene swallowed dentro il FutureBuilder dell'easy_localization → il widget resta sul fallback `SizedBox.shrink()`,
- `pumpAndSettle()` non termina mai → timeout 10 minuti → test sembra "hanging" senza errore visibile.

**Sintomo**: widget test con `EasyLocalization` che timeoutano a 10 min con un errore `TimeoutException`, niente stack trace dal codice di produzione.

**Soluzione**: in `test/helpers/pump_app.dart` chiamare `SharedPreferences.setMockInitialValues({})` prima di `EasyLocalization.ensureInitialized()`.

**Riferimento**: B0 — primo widget test smoke su `Locales.App.title.tr()` che timeoutava sistematicamente.

## Test infra: drift non preserva il flag UTC sui DateTime

**Pattern**: drift serializza `DateTime` come int microsecondi epoch. Al read ricostruisce sempre in **locale time**. Stesso istante, ma `.isUtc == false`. `DateTime.utc(2026, 1, 1) == row.startedAt` è **falso** anche se i due rappresentano lo stesso istante.

**Sintomo**: test "round-trip insert + select" falliscono con `Expected: 2026-01-01 00:00:00.000Z, Actual: 2026-01-01 01:00:00.000` (a seconda del timezone locale del runner).

**Soluzione**: assert su `isAtSameMomentAs(...)`, non su `==`. Vale per tutti i test downstream che leggono timestamp da drift.

**Riferimento**: B0 — `test/helpers/drift_in_memory_test.dart`.

## Parser NDJSON: phantom `toolCallComplete` su chiusura blocchi text

**Pattern**: il `claude -p --output-format stream-json --include-partial-messages` emette un `content_block_stop` per OGNI blocco chiuso, non solo per i `tool_use`. Il parser in `claude_process_datasource.dart:440-469` non distingue: emette `ClaudeEvent.toolCallComplete` su qualsiasi `content_block_stop`, anche quando il blocco è di tipo `text` (e quindi non è mai stato registrato in `_toolByIndex`). In quel caso emette `toolCallComplete(index=N, toolId=null, input=null)`.

**Sintomo**: `events.where(toolCall).length == 1`, `events.where(toolCallComplete).length == 2` per una sessione con 1 tool call. Il "secondo" complete è il phantom dal `text` block che chiude l'assistant turn dopo il tool.

**Effetto reale**: zero, perché il cubit filtra in `_handleEvent` linea ~777 con `if (toolId.isNotEmpty)` — i phantom vengono ignorati a downstream. Ma sono bytes inutili sullo stream e aggiungono rumore al test/debug. Non è un bug aperto: è il **contratto attuale** del parser.

**Nei test**: non assertare `calls.length == completes.length`. Filtra i complete con `toolId != null` se vuoi correlazione 1:1.

**Riferimento**: B2 — `test/features/claude/data/datasources/claude_process_datasource_normalize_test.dart`, scoperto sulla fixture `multiline_partial.ndjson`.

## PermissionServer.stop() droppa connessioni HTTP in-flight invece di restituire deny

**Pattern**: `PermissionServer.stop()` (linea 71-80) fa due cose: (a) completa tutti i `_pending` Completer con `deny`, (b) chiude il server con `force: true`. La forced close interrompe le connessioni TCP **prima** che shelf riesca a serializzare la response. Risultato: il caller HTTP riceve `HttpException: Connection closed before full header was received`, NON un response con `permissionDecision: deny`.

**Sintomo**: in test si vede `HttpException` su una richiesta sospesa quando il server viene fermato. In produzione: il subprocess `claude` (via curl) riceve un errore di rete sul PreToolUse hook → tool fallisce.

**Effetto reale**: accettabile perché `stop()` viene chiamato solo all'uscita app — il subprocess viene comunque ucciso. Ma il commento del codice dice "complete pending as deny", il che è solo metà vero (il completer viene completato, ma la response HTTP non arriva mai). È una **contraddizione tra intent e contratto osservabile**.

**Possibile fix futuro**: in `stop()` chiudere il server con `force: false` e attendere lo svuotamento delle connessioni, oppure spostare il `force: true` dopo un breve delay che lasci shelf flushare. Non è un fix richiesto adesso (il subprocess muore comunque), è documentato nel test perché un futuro refactor non rompa silenziosamente.

**Riferimento**: B4 — `test/features/claude/data/datasources/permission_server_test.dart`, test "stop() drops pending HTTP connections".

## PermissionServer accetta body malformati con un default `allow` (open)

**Pattern**: linea 100-103 — un POST con body non-JSON al `/permission` viene loggato come warning e produce un response con `permissionDecision: allow`. Il commento del codice non lo evidenzia ma è la safety-net attuale: meglio permissivo che bloccare il subprocess.

**Trade-off**: nasconde bug upstream. Se in futuro si introduce un'origin diversa che invia bodies malformati, il comportamento di default `allow` può causare esecuzione di tool senza challenge.

**Decisione consigliata** (da valutare separatamente, OUT da questo batch): cambiare il fallback a `deny` o ritornare 400. Il test attuale pin-a `allow` come contratto, quindi un cambio futuro deve aggiornare anche quel test.

**Riferimento**: B4 — test "non-JSON body resolves to allow".
