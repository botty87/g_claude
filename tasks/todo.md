# Test coverage iniziale — piano

Branch: `tests/initial-coverage`
Filosofia: i test descrivono il **comportamento atteso**. Se un test fallisce → si indaga prima il codice (potrebbe essere un bug vero); il test si modifica solo dopo aver confermato che il codice è corretto. **I test devono trovare bug**, non passare a tutti i costi.

## Principi guida (vincolanti per ogni batch)

1. **Contratto, non metodo.** Ogni `test('...')` descrive un comportamento osservabile (es. *"quando arriva sessionDead con exitCode != 0, runStatus → sessionDead E stderrTail viene appeso E il queuedPrompt NON viene drained"*). MAI nominare il metodo interno (es. `test('_handleEvent')`).
2. **Fixture reali, non sintetiche, dove possibile.** Per parser NDJSON e JSONL history: catturare output reale da `claude -p ...` e file reali da `~/.claude/projects/`, anonimizzare se servono path utente, salvare in `test/fixtures/`. Sintetizzare a mano = testare la nostra immaginazione del formato.
3. **Distinguere contratti documentati da speculazioni.** Le note "probable bugs" emerse dall'esplorazione contengono entrambi: solo i contratti documentati (es. "tool result correlato per tool_use_id", "orphan tool a fine session marcato error", "FTS body limit 200KB") sono target validi. Gli scenari speculativi (es. "what if content_block_stop arriva prima di content_block_start") restano OUT salvo evidenza che accadano.
4. **Coverage non è il target.** Misurare con `flutter test --coverage` + lcov per orientamento, ma il target è la copertura dei comportamenti rischiosi/critici, non la percentuale.
5. **Niente test di pure presentation.** Token tema, GlassPane, dialog senza logica: skip (al massimo golden test, e solo su richiesta esplicita).
6. **Niente test su data class banali.** `Failure`, freezed entity puri: testati indirettamente nei repository test.

## Convenzioni stack

- **Mock**: `mocktail` (no codegen, idiomatico con freezed/sealed). Non `mockito`.
- **Cubit**: `bloc_test` per `expectLater(emitsInOrder([...]))`.
- **SharedPreferences**: `SharedPreferences.setMockInitialValues({...})` + `getInstance()`.
- **Drift**: `NativeDatabase.memory()` per DB in-memory.
- **EasyLocalization** in widget test: wrapper helper che precarica le translations e wrappa con `EasyLocalization` (altrimenti `Locales.X.y.tr()` esplode).
- **Fixture**: `test/fixtures/{ndjson,jsonl,prefs,settings}/`.
- **Helper**: `test/helpers/` per `pumpAppWidget()`, fake `Talker`, fake `WorkspacesCubit`, ecc.

## Naming

- File test: `<source_file_name>_test.dart` accanto al sorgente nella struttura speculare in `test/`.
  - Es. `lib/features/claude/data/datasources/claude_process_datasource.dart` → `test/features/claude/data/datasources/claude_process_datasource_test.dart`.
- `group('FooCubit', () { group('when X', () { test('emits Y', ...); }); })`.
- `setUp()` per fake/mock setup, `tearDown()` per cleanup risorse.

---

## Batch (PR/commit separati, mergeable indipendentemente)

### B0 — Infrastruttura test [PREREQUISITO]

**Obiettivo**: predisporre il terreno. Senza questo, i primi test non compilano.

- [ ] Aggiungere a `pubspec.yaml` (sezione `dev_dependencies`): `mocktail`, `bloc_test`, `drift_dev` (se non presente già), eventuale `clock` per controllare il tempo nei test con timer.
- [ ] Creare struttura: `test/fixtures/`, `test/helpers/`.
- [ ] Helper: `test/helpers/pump_app.dart` → wrapper widget test con `EasyLocalization` (caricamento translations da `assets/translations/` via `EasyLocalization.ensureInitialized()` mockato). Un primo smoke widget test (es. ricerca di una chiave `Locales.Workspace.emptyState.openFolder`) deve renderizzare senza errori.
- [ ] Helper: `test/helpers/fakes.dart` → `FakeTalker` (no-op), `FakeFileSystem` per `dart:io` injectable se serve, factory `makeWorkspace(...)`, `makeClaudeMessage(...)`, `makeSlashCommand(...)`.
- [ ] Helper: `test/helpers/drift_in_memory.dart` → costruisce SQLite in-memory per `SessionsDatabase` e `AppLogsDatabase`.
- [ ] Aggiornare `CLAUDE.md`: rimuovere/aggiornare la riga *"No test in fase scaffolding..."* per riflettere la nuova policy (test obbligatori per logica pura e contratti comportamentali; widget test per componenti con drag&drop, sync controller↔cubit, decisioni utente).
- [ ] Verificare che `just test` (o `flutter test`) giri a vuoto su `test/` (anche con un test placeholder che asserisce `1 + 1 == 2`).

**Definition of done**: `flutter test` esce 0, struttura dir creata, CLAUDE.md aggiornato.

---

### B1 — Logica pura senza I/O

**Obiettivo**: validare la base. Test rapidi, zero mock, alto valore di smoke per l'infra B0.

- [ ] **`Either<L, R>`** (`lib/core/utils/either.dart`)
  - Contratto: `Left.fold` chiama `ifLeft`, `Right.fold` chiama `ifRight`.
  - Contratto: `Left.left` ritorna il valore, `Right.right` ritorna il valore.
  - Contratto: accedere a `Left.right` (o `Right.left`) lancia eccezione documentata.
  - Contratto: `isLeft`/`isRight` coerenti con la sottoclasse.
  - Equality: due `Right(1)` sono uguali (se l'implementazione lo garantisce — verificare prima nel codice).
- [ ] **`FilterSlashCommands`** (`lib/features/slash_commands/domain/usecases/filter_slash_commands.dart:7-39`)
  - Contratto: filtro vuoto ritorna lista invariata.
  - Contratto: ranking — match post-colon prefix prima di whole-trigger prefix prima di `name contains` prima di `description contains`.
  - Contratto: case-insensitivity.
  - Contratto: comando con trigger senza colon e query con colon non rompe.
- [ ] **`parseFrontmatter`** (`lib/core/utils/frontmatter.dart:1-20`)
  - Contratto: input senza prefisso `---\n` → `{}`.
  - Contratto: blocco vuoto `---\n---\n` → `{}`.
  - Contratto: chiavi/valori semplici, valori tra apici (singoli e doppi) → quote stripping.
  - Contratto: chiave duplicata → ultimo valore vince (verificare prima nel codice).
- [ ] **`SessionsDatabase._escapeFtsQuery`** (`lib/features/claude/data/datasources/sessions_database.dart:119-127`)
  - Contratto: token singolo `hello` → `"hello"*`.
  - Contratto: query multi-token → `"a"* "b"*`.
  - Contratto: doppio apice nel token raddoppiato.
  - Nota: se è privato, esporre via `@visibleForTesting` o testare indirettamente da `searchFtsIds()` con DB in-memory.

**Definition of done**: tutti i test passano, nessuna modifica al codice di produzione (se un test fallisce, si indaga il codice → potrebbe emergere il primo bug).

---

### B2 — Parser NDJSON / event normalization [ALTO VALORE]

**Obiettivo**: il parser è la superficie più rischiosa dell'intera app. Una regressione qui rompe sessioni intere senza errore visibile.

- [ ] **Cattura fixture reali**: lanciare sessioni `claude -p --output-format stream-json --bare --no-session-persistence --include-partial-messages` su prompt diversi e salvare l'output. Comando minimale per evitare hook utente, persistenza in `~/.claude/projects/`, e per ricevere `input_json_delta`.
  - `test/fixtures/ndjson/simple_text.ndjson` — solo testo, nessun tool.
  - `test/fixtures/ndjson/with_tool_call.ndjson` — un tool call (es. Read) con result.
  - **NON** `with_permission.ndjson`: il flow permessi NON passa per il parser NDJSON, passa per `PermissionServer` (HTTP). Sarà testato in B4. Driver: il sealed `ClaudeEvent` non ha `permissionRequest` — quello è un `ClaudeMessage` emesso dal cubit quando il PermissionServer chiama il resolver. In `claude -p` standalone non scriviamo il `settings.json` con la porta del server, quindi il PreToolUse hook non viene innescato.
  - `test/fixtures/ndjson/with_error.ndjson` — sessione che termina con errore.
  - `test/fixtures/ndjson/synthetic/with_rate_limit.ndjson` — `rate_limit_event` non è riproducibile deterministicamente. Cartella `synthetic/` separata; commit con README che spiega "shape osservata in produzione, costruito a mano".
  - `test/fixtures/ndjson/multiline_partial.ndjson` — tool call con `input_json_delta` su molti chunks (richiede `--include-partial-messages`).
- [ ] **Test parser** (`claude_process_datasource_test.dart`):
  - Per ogni fixture: leggere file → passare ogni riga al normalizer → asserire la sequenza di `ClaudeEvent` attesi (tipo + campi chiave).
  - Contratti documentati:
    - `system.init` → `ClaudeEvent.sessionInit` con sessionId, model, tools, skills, slashCommands, plugins (default vuoti se mancanti).
    - `content_block_delta.text_delta` → `textChunk` con testo concatenato.
    - `content_block_start.tool_use` → `toolCall` con toolId/name/index.
    - `input_json_delta` → accumulato in `_ToolBlockState.partialJson`.
    - `content_block_stop` su un tool aperto → `toolCallComplete` con input parsato.
    - `user.tool_result` → `toolResult` con toolUseId + content flatten.
    - `assistant.message` con content list di blocchi → `assistantMessage` con testo concatenato.
    - `result.is_error == true` → `errorEvent`.
    - `result` (success) → `taskComplete`.
    - `rate_limit_event` → `rateLimit`.
  - Edge case dal codice (NON speculazione, presenti come default `??`):
    - sessionInit con `tools: null` → emit con `tools = []`.
    - sessionInit con `model: null` → emit con `model = ''`.
    - tool_result con content `String` → flatten letterale.
    - tool_result con content `List<Map>` → flatten via type-specific (text/image).
    - tool_result con content `null` → flatten = ''.
    - Tipo evento sconosciuto → no emit, no crash (smoke test con riga `{"type":"foo_unknown"}`).
    - Riga JSON non parsabile → loggata, parser continua sulla successiva.
- [ ] **NON testare** (speculazioni dell'esplorazione, OUT salvo evidenza):
  - `content_block_stop` prima di `content_block_start` (out-of-order).
  - input_json_delta senza mai un content_block_stop terminale.
  - Index collision tra tool concorrenti.

**Definition of done**: parsing di tutte le fixture reali produce gli eventi attesi senza eccezioni.

---

### B3 — JSONL history reader [ALTO VALORE]

**Obiettivo**: la cronologia chat è dati persistenti: corruzione qui = perdita dati per l'utente.

- [ ] **Cattura fixture reali**: copiare 3–4 file reali da `~/.claude/projects/{cwd-encoded}/{sessionid}.jsonl`, anonimizzare path, salvare in `test/fixtures/jsonl/`.
- [ ] **Test `ClaudeHistoryDataSource`** (`claude_history_datasource_test.dart`) — usare un'implementazione che accetta path radice via DI (o tmp dir):
  - **`encodeCwd`** (linea 64): contratto regex (alfanumerico → `-`); test su path con spazi, unicode, `~`, dots.
  - **`scanWorkspace`**:
    - Directory inesistente → ritorna `[]`.
    - Directory vuota → `[]`.
    - File non `.jsonl` → ignorato.
    - File JSONL malformato → onParseError invocato, scan continua.
    - Sessione senza title né summary → title fallback (verificare a `''` o nome file).
    - Sort per `lastMessageAt` decrescente.
  - **`readSession`**:
    - Messaggi user con content `String` → emesso come singolo testo.
    - Messaggi user con content `List<block>` → blocchi text concatenati con newline.
    - Messaggi assistant con multiple text blocks → concatenati.
    - Tool block + tool_result correlati per `tool_use_id` → tool result attaccato al tool right.
    - **Orphan tool** (tool senza result a fine sessione) → marcato con status error (contratto documentato).
    - tool_result `String` content → usato come è.
    - tool_result `List` content → JSON-encoded.
    - tool_result `null` content → ''.
  - **`readFullText`**:
    - Limite 200KB (linea 301): contenuto totale > limite → troncamento, ritorno parziale (contratto da verificare nel codice).
  - **`exportSessionMarkdown`**: smoke test su una fixture, output contiene marker user/assistant/tool, niente eccezioni.

**Definition of done**: tutte le fixture reali parsano correttamente; orphan tool detection verificata.

---

### B4 — PermissionServer + ClaudeSettingsWriter

**Obiettivo**: il server di permessi è il punto di sincronizzazione critico tra subprocess e UI. Difetti qui → comportamento incoerente del CLI o blocchi.

- [ ] **`PermissionServer`** (`lib/features/claude/data/datasources/permission_server.dart`):
  - Setup: avviare server reale su porta effimera (loopback), mandare richieste HTTP via `package:http` o `dart:io HttpClient`.
  - Contratti:
    - GET / altri path != `/permission` → 404.
    - POST `/permission` con JSON valido + resolver registrato che ritorna `allow` → response 200, `permissionDecision == "allow"`.
    - POST con resolver che ritorna `deny` → response 200, decision `deny`.
    - POST con resolver che ritorna `ask`, interactive handler registrato che chiama `respond(requestId, allow)` → response `allow`.
    - POST con resolver `ask` MA nessun interactive handler → response `deny` (fallback safety).
    - POST senza resolver → response `allow` (default permissivo iniziale).
    - POST con JSON malformato → response 200 con `allow` (osservare contratto attuale linea 100-102, eventualmente flaggare come weakness in `tasks/lessons.md`).
    - Risposta MAI contiene `updatedInput` (invariante linea 150-155).
    - Timeout interactive 5min: simulare con `fakeAsync` o `clock` injection — verificare che dopo timeout viene risposto `deny` e pending viene rimosso.
    - `respond()` chiamato due volte con stesso requestId: secondo è no-op, niente eccezioni.
- [ ] **`ClaudeSettingsWriter`** (`lib/features/claude/data/datasources/claude_settings_writer.dart`):
  - Contratti:
    - `ensure(port)` con porta nuova → crea file, ritorna path.
    - `ensure(port)` con stessa porta → cache hit, stesso path, no riscrittura.
    - File contiene struttura JSON con hook `PreToolUse` → comando curl con porta corretta.

**Definition of done**: tutti gli scenari di decisione coperti, timeout testato deterministicamente.

---

### B5 — Repository con datasource mockati

**Obiettivo**: validare la traduzione exception → Failure e la logica di caching/coalesce.

- [ ] **`FileContentRepositoryImpl`** (`lib/features/editor/data/repositories/file_content_repository_impl.dart`):
  - LRU cache: 30 entries → 31° eviction del LRU.
  - Cache da 10MB: file totale > 10MB → eviction parziale.
  - Mtime change → invalidazione: stesso path, mtime diverso → `_inFlight` reload, ritorna nuovo content.
  - Concurrent reads stesso path: due call simultanee → datasource invocato 1 volta sola (`_inFlight` coalesce).
  - File too large → `ValidationFailure`.
  - Binary file → `ValidationFailure`.
  - Path non esistente → `NotFoundFailure`.
  - Eccezione generica datasource → `UnexpectedFailure`.
- [ ] **`WorkspaceRepositoryImpl`** (`lib/features/workspace/data/repositories/workspace_repository_impl.dart`):
  - `openWorkspace(path)` con path valido → `Right(Workspace)`.
  - Path inesistente → `Left(NotFoundFailure)`.
  - Path è file (non dir) → `Left(ValidationFailure)`.
  - `loadClaudeMd(path)` → ritorna contenuto se esiste, `null` se no, mai eccezione bubble.
- [ ] **`ChatHistoryRepositoryImpl`**:
  - Mock `SessionsIndexDataSource` + `ClaudeHistoryDataSource`.
  - Search → query passa via FTS, ritorno mappato a summary.
  - Delete → file rimosso + index invalidato (verificare ordine).
  - Export → ritorna path destinazione, errore I/O → `UnexpectedFailure`.

**Definition of done**: tutte le mappature exception → Failure coperte.

---

### B6 — Cubit (state machine + integration con use case mockati)

**Obiettivo**: i cubit sono il cuore del comportamento osservabile. Test qui = test del flusso utente.

- [ ] **`WorkspacesCubit`** (`lib/features/workspace/presentation/cubit/workspaces_cubit.dart`):
  - `openPath(path)` con path valido → emit `loaded` con il workspace + activeId aggiornato.
  - `openPath(path)` con path già aperto → activeId aggiornato, lista invariata.
  - `openPath(path)` con path invalido → emit `loaded` con `lastFailure`, lista invariata.
  - `closeWorkspace(id)` su workspace attivo → activeId scivola al sibling (verificare regola: precedente? successivo?).
  - `closeWorkspace(id)` ultimo workspace → activeId = null, stato torna `initial` (verificare nel codice).
  - `restore()`: prefs con JSON valido → emit loaded; prefs corrotte → emit initial + log warning, no crash.
  - Persistenza debounce 250ms (verificare in codice): rapide chiamate consecutive → 1 sola write a SharedPreferences.
- [ ] **`FileTabsCubit`** (`lib/features/editor/presentation/cubit/file_tabs_cubit.dart`):
  - `openFile(wsId, path)`: prima volta → preview path settato; seconda volta stesso file → activePath, niente pin.
  - `pinFile(wsId, path)`: preview path → openPaths, previewPath cleared.
  - `closeFile`: tab attivo → next tab attivo; ultimo tab → activePath null.
  - `reorderPinned`: ordine cambia.
  - **Orphan filter** (`restore()`): prefs con tab di workspace non più esistente → filtrati out.
  - **Auto-close on delete** (file watcher, debounce 300ms): mock dello stream FileSystemEvent.delete → tab chiuso dopo 300ms.
- [ ] **`ExplorerCubit`** (`lib/features/explorer/presentation/cubit/explorer_cubit.dart`):
  - `ensureRootLoaded`: prima volta → carica + emit; seconda volta → no-op (cached).
  - `toggleFolder`: prima volta su dir → loading=true → loaded con children; seconda volta → expanded toggle, niente reload.
  - `revealPath`: 2 fasi — fase 1 sync expand cached, fase 2 async load missing, merge senza flicker.
  - `refresh`: refresh root + tutte le dir espanse.
- [ ] **`ClaudeSessionsCubit`** (`lib/features/claude/presentation/cubit/claude_sessions_cubit.dart`) — il più complesso:
  - `sendPrompt(wsId, text, ...)` con session idle → runStatus=running, messaggio user appeso, stream subscribe.
  - Stream emette `textChunk`: messaggio assistant streaming, testo accumulato (debounce 16ms).
  - Stream emette `toolCall` poi `toolCallComplete`: tool message appeso con status running poi completed.
  - Stream emette `toolResult`: tool message correlato per toolUseId, output settato.
  - Stream emette `taskComplete`: runStatus=idle.
  - Stream emette `errorEvent`: runStatus=error, lastError settato.
  - Stream emette `sessionDead` con exitCode 0: runStatus=idle.
  - Stream emette `sessionDead` con exitCode != 0: runStatus=sessionDead, stderrTail appeso, queuedPrompt NON drained.
  - `setQueuedPrompt` durante run: testo memorizzato, drained al taskComplete (idle).
  - `setQueuedPrompt` con text vuoto: clearQueuedPrompt.
  - `stopRun`: kill subprocess, cleanup timer, runStatus=idle.
  - `setModel/setPermissionMode/setEffort/setThinking`: emit + persist a SharedPreferences (round-trip).
  - `toggleMcpServer(wsId, name, false)`: aggiunto a disabledMcpServers, persistito.
  - `answerPermission(wsId, msgId, decision)`: trovato message permissionRequest non answered → answered=true + decision settata, PermissionServer.respond() invocato.
  - Filtro tool per permissionMode=plan: tool write/edit filtrati (read-only).

**Definition of done**: tutti i transition di stato verificati. Eventuale bug emerso (es. queuedPrompt drained su error) → fixarlo nel codice prima di toccare il test.

---

### B7 — Widget test mirati

**Obiettivo**: verificare i contratti UI dei componenti dove la regressione è invisibile fino a che l'utente non la incontra. Particolare attenzione al pattern `single source of truth` (memoria `feedback_single_source_of_truth.md`).

- [ ] **`QueuedPromptCard`** (`lib/features/claude/presentation/widgets/queued_prompt_card.dart`):
  - Render solo se `queued != null && isBusy`.
  - Edit text → `setQueuedPrompt(wsId, newText)` invocato sul cubit (verifica live read, no mirror locale).
  - Tap remove icon → `clearQueuedPrompt(wsId)` invocato.
  - State del cubit cambia esternamente → controller text aggiornato.
- [ ] **`PermissionRequestCard`**:
  - Render con `toolInput.isEmpty`: niente expand button.
  - Render con `toolInput` non vuoto: tap expand → JSON visibile.
  - Tap deny → `onDecide(deny)` chiamato.
  - Tap allow once → `onDecide(allowOnce)`.
  - Tap allow always → `onDecide(allowAlways)`.
  - `message.answered == true` → render answered (icona + colore), pulsanti disabili.
- [ ] **`ClaudeTerminalPane`** drag&drop:
  - Drop di un file → `setInputDraft` invocato con `attachments` aggiornato (live read draft).
  - Drop di un duplicato → no-op (filtro path già presente).
  - Drop di una directory → `ChatAttachment(kind: directory)` creato.
- [ ] **`Hoverable` double-tap debounce** (`lib/shared/widgets/hoverable.dart`):
  - Tap singolo → `onTap` dopo `kDoubleTapTimeout`.
  - Doppio tap entro `kDoubleTapTimeout` → `onDoubleTap` invocato, `onTap` NO.
- [ ] **`FileTabsBar`** (`lib/features/editor/presentation/widgets/file_tabs_bar.dart`):
  - openFiles vuoto → barra vuota.
  - Cambio activePath → scroll animato (verificare via `controller.offset` cambio).
  - Tap su tab → `setActiveFile()` invocato.
  - Doppio click su preview tab → `pinFile()` invocato.

**Definition of done**: ogni widget test usa il pattern `single source of truth` (no useState che mirroreggia stato cubit), e i mock cubit verificano gli scope dei rebuild.

---

## Out of scope (questo ciclo)

- Integration test con subprocess `claude` reale (richiede CLI installata, non idempotente, OUT).
- Golden test (UI styling). Da considerare in cicli successivi se richiesto.
- Test su `AppColors`, `AppSpacing`, `AppRadii`, `AppTypography`. Sono costanti — niente da verificare.
- Test su token Theme, GlassPane, modal puramente presentation.
- Test su bootstrap `main.dart` (non testabile direttamente).
- `_prewarmPersistedTabs` standalone: bonus se l'estraiamo da main.dart prima.

---

## Open questions per l'utente

Prima di partire con B0, conferma o redirigi:

1. **Ampiezza piano**: ok piano completo poi implementazione iterativa per batch (B0 → B1 → ... → B7), un commit per batch, advisor + review fra B2 e B3 (entrambi alto rischio)?
2. **Fixture reali**: posso lanciare alcune sessioni `claude -p` reali per catturare NDJSON, o preferisci fornirmele tu? (Senza fixture reali in B2 il valore del test cala drasticamente.)
3. **CLAUDE.md aggiornamento**: ok includerlo come task del B0?
4. **Aggiornamento policy `lessons.md`**: ogni bug emerso da un test che fallisce e poi richiede fix del codice — lo capturiamo in `tasks/lessons.md` come pattern. Confermi?

---

## Review (da compilare a fine implementazione di ogni batch)

### B0 — Infrastruttura test (DONE)

**File aggiunti/modificati**:
- `pubspec.yaml`: aggiunti `mocktail ^1.0.4`, `bloc_test ^10.0.0`, `fake_async ^1.3.1`.
- `test/helpers/pump_app.dart`: wrapper `pumpAppWidget()` per widget test che richiedono `Locales.X.y.tr()`. Mocka `SharedPreferences` prima di `EasyLocalization.ensureInitialized()`.
- `test/helpers/pump_app_test.dart`: smoke test che renderizza `Locales.App.title` e verifica risoluzione (`'Claude Code GUI'`); test sanity opposto che pin-a il contratto (la chiave letterale non deve apparire).
- `test/helpers/fakes.dart`: factory `makeWorkspace(...)`.
- `test/helpers/drift_in_memory.dart`: `makeAppLogsDb()`, `makeSessionsDb()` su `NativeDatabase.memory()`. Helper `collect()` per stream.
- `test/helpers/drift_in_memory_test.dart`: smoke test insert/select round-trip + cascade FK + verifica creazione tabella FTS5.
- `test/fixtures/{ndjson,jsonl,prefs,settings}/`: cartelle predisposte (vuote, popolate da B2/B3/B4).
- `test/widget_test.dart`: rimosso (era placeholder `1+1==2`).
- `CLAUDE.md`: rimossa la riga "No test in fase scaffolding"; aggiunta sezione **Test policy** con stack, naming, contratti vs metodi, regole "trovare bug".

**Bug emersi durante B0** (catturati in `tasks/lessons.md`):
1. `EasyLocalization` sotto `flutter_test` hanga indefinitamente se `SharedPreferences` non è mockato — `MissingPluginException` swallowed nel FutureBuilder, `pumpAndSettle` non si chiude, timeout 10 min senza errore visibile.
2. Drift non preserva il flag UTC sui `DateTime`: `==` fallisce su round-trip insert/select. Usare `isAtSameMomentAs` per asserire l'istante.

**Outcome**: `flutter test` → 33 tests passed. `dart analyze` → 0 issues.

### B1 — Logica pura senza I/O (DONE)

**File aggiunti**:
- `test/core/utils/either_test.dart` — 9 test su `fold`, `left`/`right` getters (asserito che lanciano `Exception`, non `Error`), `isLeft`/`isRight`, e nullable type parameters (verificato che `Right(null)` resta Right e dispatcha sul ramo destro).
- `test/core/utils/frontmatter_test.dart` — 13 test su delimiter (`---\n` + `\n---\n`), key/value, quote stripping (matched only), trim, lines without colon skipped, empty key dropped, valore con `:` interno preservato, duplicate keys (last wins). **Documentato come contratto attuale**: CRLF input non supportato.
- `test/features/slash_commands/domain/usecases/filter_slash_commands_test.dart` — 16 test su tier ranking (post-colon > whole prefix > name-contains > desc-contains, mutuamente esclusivi), normalizzazione query (leading `/` strip via `replaceFirst`, lowercase, trim), passthrough (empty/whitespace/`/` only), stable order all'interno di un tier.
- `test/features/claude/data/datasources/sessions_database_test.dart` — 12 test su `searchFtsIds`/`upsertSessionFts`/`deleteSessionFts`/`ftsIdsForWorkspace` con DB in-memory: empty/whitespace query → `[]` no SQL, prefix match single token, AND multi-token, workspace scoping, no crash su FTS5 metacaratteri (NOT/OR/AND/`*`/`(`/`+`/`"` interno), limit honored, upsert replace semantics, delete drops from search.

**Bug emersi durante B1**:
- Nessun bug nel codice di produzione. Tutti i contratti documentati passano al primo colpo.
- Un mio errore di compilazione (variabile locale `contains` shadow-ava il matcher `contains()` di flutter_test). Risolto rinominando `containsOnly`.

**Documentazione contratti rilevanti per i prossimi batch**:
- `parseFrontmatter` ignora chiavi senza valore solo se chiave è vuota (linea col solo `:` viene scartata).
- `FilterSlashCommands` usa `replaceFirst` sulla `/` iniziale: query `//foo` → `/foo` non matcha `foo`. Documentato.
- `_escapeFtsQuery` quota ogni token con `"..."` e raddoppia i `"` interni: garantisce che ogni input utente è una query syntactically valid per FTS5, anche se semanticamente non matcha nulla.

**Outcome**: `flutter test` → **82 passed** (66 esistenti + 16 nuovi su slash filter — il delta esatto nei singoli file: 9+13+16+12 = 50 nuovi, gli altri 33 erano i pre-esistenti). `dart analyze` → 0 issues.

### B2 — Parser NDJSON / event normalization (DONE)

**Fixture catturate** (real run, anonimizzate `s|/Users/marco.bottichio|/Users/USER|g` e `s|/private/tmp/g_claude_fixtures/wd|/tmp/wd|g`):
- `test/fixtures/ndjson/simple_text.ndjson` — 13 righe, sessione semplice testo, terminata con `taskComplete`.
- `test/fixtures/ndjson/with_tool_call.ndjson` — 36 righe, Read tool call con result.
- `test/fixtures/ndjson/with_error.ndjson` — 3 righe, sessione `--bare` con `is_error: true` (auth_failed) → `errorEvent`.
- `test/fixtures/ndjson/multiline_partial.ndjson` — 355 righe, Write tool con 334 `input_json_delta`.
- `test/fixtures/ndjson/synthetic/with_rate_limit.ndjson` — 3 righe sintetiche, README documenta sorgente shape.

**Modifiche al codice di produzione**:
- `lib/features/claude/data/datasources/claude_process_datasource.dart`: aggiunti `@visibleForTesting` `normalizeForTest()` (alias pubblico di `_normalize`) e `resetParserStateForTest()` (clear di `_toolByIndex`). Import di `flutter/foundation.dart` per l'annotation.

**Test scritti**: `test/features/claude/data/datasources/claude_process_datasource_normalize_test.dart` — 27 test su 5 fixture (4 reali + 1 sintetica) + scenarios di robustezza.

Coperti i contratti:
- `simple_text`: sessionInit non vuoto (sessionId/model dal JSON), hook envelopes ignorati, textChunk non vuoti, taskComplete singolo, no error events.
- `with_tool_call`: ordering `toolCall` → `toolCallUpdate` → `toolCallComplete`, toolId threading via `_toolByIndex`, `toolResult.toolUseId` correlato, `assistantMessage` finale.
- `with_error`: `result.is_error == true` → `errorEvent` (NO taskComplete), messaggio non vuoto.
- `multiline_partial`: >50 update events, ogni update bracketed dal proprio toolCall e dal complete reale, input map completo con `file_path`.
- `synthetic with_rate_limit`: `rateLimit` con status + resetsAt.
- Robustezza: tipo sconosciuto / inner type sconosciuto / event non-Map → 0 events no crash. sessionInit con campi mancanti → defaults vuoti. text_delta vuoto → no textChunk. content_block_stop senza start → toolCallComplete con toolId/input null. tool_result content null → '', is_error → propagato. Lista mixed text/image → flatten con newline join.

**Bug emerso**: 1 test fallito al primo run — assumevo erroneamente `calls.length == completes.length`. Indagine sul codice ha rivelato che il parser emette **phantom toolCallComplete** anche su `content_block_stop` di blocchi `text` (non `tool_use`). Documentato in `tasks/lessons.md`. Il cubit downstream filtra per `toolId.isNotEmpty` quindi il phantom è invisibile in produzione, ma è codice che emette eventi non utili. Non un fix richiesto, è il **contratto attuale** del parser. Aggiornato il test per rispettare il contratto reale + un test dedicato che pin-a la shape phantom (`toolId=null, input=null`).

**Outcome**: `flutter test` → **109 passed**. `dart analyze` → 0 issues.

### B3 — JSONL history reader (DONE)

**Strategia fixture**: il sandbox del harness ha bloccato la copia di file da `~/.claude/projects/` (sensitive-file guard). Pivot ad **all-synthetic**, ma con shape verificate via `jq` su file reali (top-level keys, type values, content variants — documentato in `test/fixtures/jsonl/synthetic/README.md`). Una fixture per concetto (no mega-fixture): 9 fixture mirate.

**Fixture create** (tutte sotto `test/fixtures/jsonl/synthetic/`):
- `text_only_session.jsonl` — user/assistant testo puro.
- `tool_flow.jsonl` — tool_use + tool_result correlati.
- `orphan_tool.jsonl` — tool_use senza tool_result (orphan).
- `string_content_user.jsonl` — content come String (legacy).
- `summary_fallback.jsonl` — title via fallback summary.
- `slash_command_title.jsonl` — slash-command title rule.
- `sidechain_meta_filter.jsonl` — filter isSidechain/isMeta.
- `noise_filter.jsonl` — system/queue/permission/snapshot ignore.
- `mixed_tool_result.jsonl` — tool_result content List.

**Modifiche al codice di produzione**:
- `ClaudeHistoryDataSourceImpl.withProjectsDir(talker, projectsDir)` — costruttore `@visibleForTesting` che pinna la projects dir senza dipendere da `$HOME`.

**Test scritti**: `test/features/claude/data/datasources/claude_history_datasource_test.dart` — 30 test su 4 metodi pubblici (`encodeCwd`, `scanWorkspace`, `readSession`, `readFullText`, `deleteSession`, `exportSessionMarkdown`).

Contratti pinnati:
- **encodeCwd**: ogni non-alfanumerico → `-`. Whitespace, dots, slashes tutti convertiti uno-a-uno.
- **scanWorkspace**: dir mancante → `[]`. Dir vuota → `[]`. File non `.jsonl` skippati. Title da primo user message → cleaned via xml-tag-regex + whitespace-normalize. Slash-command rule: drop `/cmd ` prefix, mantieni args. summary fallback se nessun user title. **isSidechain/isMeta filtrati** sia da messageCount sia da title candidate. Sort per `lastMessageAt` desc. Fallback a `fileMtime` quando nessun timestamp parseable.
- **readSession**: emette tool TWICE — prima `running` (al tool_use), poi `completed` (al tool_result), con stesso `id`. Orphan tool (no result) → emesso a fine stream con status `error, isError: true`. Content shapes: String → user message diretto. List → text blocks concatenati con `\n`, tool_result correlati per `tool_use_id`. Lista mixed → JSON-encoded come output. is_error → propagato. Linee JSON malformate → loggate, non crash. system/queue/permission/snapshot/sidechain/meta tutti filtrati.
- **readFullText**: 200KB cutoff. Solo testo da user/assistant blocks (NO tool_use/tool_result content). Joined con `\n`.
- **deleteSession**: rimuove file presente. `FileSystemException` se assente.
- **exportSessionMarkdown**: scrive markdown con sezioni User/Assistant/Tool, ritorna destinationPath, crea directory intermedie.

**Bug emersi durante B3**: nessuno nel codice di produzione. Due errori miei, entrambi corretti **senza toccare il codice**:
1. Default `encodedPath = 'test-workspace'` dimenticava il dash leading da `encodeCwd('/test/...')`. Corretto a `-test-workspace`.
2. Test su `tool_flow` assumeva 1 tool message, ma il vero contratto è **2** (running + completed con stesso id). Test riformulato per descrivere il vero contratto del codice.

**Outcome**: `flutter test` → **139 passed**. `dart analyze` → 0 issues.

### B4 — PermissionServer + ClaudeSettingsWriter (DONE)

**Strategia**: bind di un Shelf server reale su loopback ephemeral port + POST HTTP reali, mirroring del wire protocol di produzione (curl dal subprocess). Più robusto che fakare `shelf.Request`.

**Test**: 
- `test/features/claude/data/datasources/permission_server_test.dart` — 16 test su routing (404 per GET, path != `/permission`), decisioni resolver-driven (allow/deny/ask con interactive handler), fallback safety (no resolver → allow, ask senza handler → deny), shape invariants (mai `updatedInput`), lifecycle (`start()` idempotente, `stop()` droppa connessioni in-flight).
- `test/features/claude/data/datasources/claude_settings_writer_test.dart` — 5 test su shape JSON (hooks.PreToolUse con curl + matcher `*` + max-time 120), idempotenza per stessa porta (no rewrite), porta diversa → file nuovo.

**Bug emersi durante B4** (documentati in `tasks/lessons.md`, NON fixati — contratto attuale):
1. `PermissionServer.stop()` afferma di completare i pending con `deny`, ma chiude il server con `force: true`. La completion del completer arriva ma la response HTTP non viene mai serializzata: il caller riceve `HttpException`. Test pin-a il contratto reale.
2. `PermissionServer` accetta body malformati restituendo `allow`. È la safety-net attuale ma nasconde bug upstream. Test pin-a il contratto attuale.

**Outcome**: `flutter test` → **160 passed**. `dart analyze` → 0 issues.

### B5
_TBD_

### B6
_TBD_

### B7
_TBD_

---

## Archivio piani precedenti

Il vecchio contenuto di questo file (Shortcut cycle + set diretti per Sforzo/Pensiero/Permission) è stato spostato/archiviato. Ripristinabile da git history (commit precedenti su `main`).
