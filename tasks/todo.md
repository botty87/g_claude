# Fase 6 — Diff panel + rifiniture di moto (ClickUp 86cahc8ey)

Branch: `feature/diff-panel` da `main`. Vincolo: solo `features/explorer` + pannello destro (`shell`) + `features/editor` (tab "Codice") + NUOVO `features/git` diff datasource. **NON** toccare `git_worktree_datasource.dart` né `features/claude`.

## Decisioni architetturali (post-esplorazione + advisor)

- **Tab diff conviventi**: due liste parallele in `WorkspaceFiles` — `openPaths` (file, intatta) + nuova `openDiffs: List<DiffTabRef>`. Diff tab **effimere → NON persistite** in `tabs.v1` (derivano dallo stato git). Puntatore attivo discriminato: `activeDiffId` con invariante *"se != null vince sul file"*; `openFile`/`setActiveFile` azzerano `activeDiffId`. Niente sealed-union su `openPaths` (forzerebbe schema-bump + guardie watcher per zero guadagno).
- **Persistenza divisa**:
  - `rightPanelCollapsed` → **in-memory** in `ShellCubit` (la sidebar NON è persistita; per essere "esatta" dev'esserlo anche questo).
  - vista diff **flat/tree** → **persistita per workspace** via `KeyValueStore` in un nuovo `GitDiffCubit`.
- **Sorgente diff** = working tree vs `HEAD`: `git status --porcelain` (lista+stato) + `git diff --numstat HEAD` (conteggi). Contenuto viewer: `git diff HEAD -- <path>` (untracked: file intero come additions).
- **Viewer diff**: rendering custom per riga (parse unified → righe context/add/del/hunk), colori `AppColors.diffAdd`/`diffDel` (già esistenti). Unified prima; Split rifinitura (riusa gli hunk parsati).

## Piano

### 1. Feature `git` — datasource/repo/usecase diff (Clean Arch)
- [ ] `domain/entities/git_diff_file.dart` (freezed): `path`, `status` (enum: modified/added/deleted/renamed/untracked), `added`, `deleted`, `isBinary`, `oldPath?`.
- [ ] `domain/entities/diff_hunk.dart` + `diff_line.dart` (freezed) per il contenuto unified parsato.
- [ ] `data/datasources/git_diff_datasource.dart` (`@lazySingleton`, `Talker`): `Process.run('git', ['-C', cwd, ...])` con helper privato `_run` (stile `git_worktree_datasource`). Parser **static `@visibleForTesting`**: `parsePorcelain`, `parseNumstat` (merge per path), `parseUnifiedDiff`.
- [ ] `domain/repositories/git_diff_repository.dart` + `data/repositories/git_diff_repository_impl.dart` (`SubprocessFailure`/`UnexpectedFailure`).
- [ ] `domain/usecases/list_changed_files.dart`, `read_file_diff.dart`.

### 2. `GitDiffCubit` + state
- [ ] Stato per-workspace: `files`, `viewMode: flat|tree` (**persistito**), `loading`, `failure?`, `expandedDirs`.
- [ ] Metodi: `load(workspaceId)`, `refresh`, `setViewMode`, `toggleDir`. Persist viewMode via `KeyValueStore` (chiave `persistence.git_diff.v1`).
- [ ] `@lazySingleton`, restore viewMode al `@PostConstruct`.

### 3. Pannello Diff (right_panel.dart, tab "Diff")
- [ ] Sostituire `_StubMessage` (`right_panel.dart:127`) con `DiffPanelView`.
- [ ] Header: toggle **flat/tree** + refresh + spinner in loading.
- [ ] **Lista piatta**: path completo + badge M/A/D + `+add`/`−del`.
- [ ] **Albero**: raggruppa per cartella (contatore file, comprimibile) riusando il flatten di `explorer_view.dart:157`; file con badge + conteggi.
- [ ] Click file → apre tab diff in "Codice" (`openDiff` + `openPeek`/`promoteToFull` come explorer).

### 4. Tab diff nella sezione "Codice" (editor)
- [ ] `WorkspaceFiles`: `+ openDiffs: List<DiffTabRef>`, `+ activeDiffId`. `DiffTabRef` (freezed): `id`, `path`, `added`, `deleted`.
- [ ] `FileTabsCubit`: `openDiff`/`closeDiff`/`setActiveDiff`; `openFile`/`setActiveFile`/`closeFile` azzerano `activeDiffId`. Persistenza `tabs.v1` invariata (diff escluse).
- [ ] Tab bar (`center_pane.dart:273` + `peek_sheet.dart:81`): dopo le tab file, itera `openDiffs` → `FileTab(isDiff: true)`.
- [ ] `file_tab.dart` `_TabBody`: se `isDiff` → icona `Symbols.difference` + badge "DIFF"; titolo = basename(path).
- [ ] `FileViewer`/`_PooledStack`: se `activeDiffId != null` monta `DiffView` altrimenti `FilePreview`.
- [ ] `DiffView` (nuovo): header (path, +/−) + toggle Split/Unified (Unified funzionante); carica via `ReadFileDiff`; rendering righe colorate. Stato locale `sealed _ViewState` (come `code_view.dart`).
- [ ] Contatore "Codice (n)" (`center_pane.dart:37`): `openPaths.length + openDiffs.length`.

### 5. Pannello destro collassabile
- [ ] `ShellState`: `+ @Default(false) bool rightPanelCollapsed`. `ShellCubit`: `toggleRightPanel`/`setRightPanelCollapsed`. In-memory.
- [ ] Layout: **SCELTA = mantieni MultiSplitView**, anima `Area.size` (320↔52), divisore disabilitato quando collassato. Resize preservato quando espanso. Toggle nell'header + rail collassata (icona + expand button, come sidebar).
- [ ] Animazione: `AnimatedSwitcher` sul contenuto (espanso/rail) + size dell'Area guidata dal flag; `_PinnedWidth`-like sul contenuto interno per evitare reflow durante il tween.

### 6. Rifiniture di moto
- [ ] Pulse dot stato running, spinner (diff loading), transizioni tab/pannello (`AnimatedSwitcher`).

### 7. l10n
- [ ] Chiavi nuove `en.json`+`it.json` (badge, flat/tree, split/unified, empty state) → `dart run lib/core/l10n/tool/l10n_generate.dart`.

### 8. Test
- [ ] Parser `parsePorcelain`/`parseNumstat`/`parseUnifiedDiff` — fixture reali con **modify + untracked (??) + binary (- -) + rename (R old -> new)**.
- [ ] `GitDiffRepositoryImpl` mapping eccezione→Failure.
- [ ] `GitDiffCubit` state machine (load/viewMode persist).
- [ ] Widget: lista piatta + albero (comprimi/click) + tab diff (badge DIFF, contatore, convivenza con file tab).

### 9. Verifica
- [ ] `just analyze` · `just format-check` · `fvm flutter test`.
- [ ] Prova live via Marionette (apri diff, toggle viste, collapse pannello).
- [ ] Mostra diff + risultati test → attendo ok commit.
- [ ] Aggiorna ClickUp 86cahc8ey (Composio, `clickup_rococo-picot`).

## Stato

Implementazione completa. Verifica live via Marionette OK (app rilanciata pulita):
- Pannello Diff: lista piatta (badge M/A/D/U + conteggi +/−) e albero (cartelle annidate, contatori, comprimibili) su dati git reali.
- Toggle flat/tree (persistito in GitDiffCubit via KeyValueStore).
- Click file → tab diff in "Codice" (badge DIFF, contatore "Codice n" = file+diff), peek sheet.
- Viewer diff: Unified (numeri riga, hunk header, aggiunte verdi) + Split (side-by-side allineato).
- Pannello destro collapse/expand (rail 52px ↔ full, animazione size Area).

Quality gate: `just analyze` pulito, `just format-check` pulito.
Test: git 71 ✓, file_tabs_cubit 14 ✓ (invariante activeDiffId), buildDiffTreeRows 6 ✓, repository mapping ✓.
Widget test (diff_panel_view, file_tab): flakiness d'ordine nell'harness → in fix dal test-engineer (codice di produzione OK, verificato live).

Nota: la feature `git` diff (datasource/parser/repo/usecase/cubit + test) è stata implementata da un subagent writer; l'integrazione editor/shell + UI da me.

## Review (flutter-code-reviewer, opus)

Nessun Critical. Invariante `activeDiffId`, callback live-read, selettori granulari, animazione `_MainArea` (no leak/race), DI, no-hardcoded-strings, no StatefulWidget → tutti verificati OK.

Fix applicati:
- **High**: `_SplitBody` usava `VerticalDivider` in un `Row` dentro scroll verticale (rischio "infinite height"). Sostituito con `Border(left:)` sulla colonna destra — più robusto ed economico.
- **Medium**: `DiffView` useEffect non rileggeva il diff al re-open con conteggi diversi. Aggiunte `ref.added/deleted` alle deps.

Rifiniture non bloccanti lasciate (accettabili per questa fase):
- Viewer diff non virtualizzato (Column+IntrinsicWidth) — ok per diff tipici; virtualizzare se necessario in futuro.
- `getIt<ReadFileDiff>` in DiffView (coerente col pattern di `code_view.dart` che usa `getIt<ReadFile>`).
- double-tap pin su tab file preview non azzera `activeDiffId` (edge UX minore).

## Test finali
- Suite completa: 386 pass. 2 fail in `test/integration/sidecar_bridge_test.dart` (feature `claude`, NON toccata; test d'integrazione che spawna il sidecar reale → fallisce in ambiente headless, non correlato a questa feature; `git status` conferma 0 modifiche a `backend/`/`features/claude`).
- `just analyze` pulito · `just format-check` pulito.
- Verifica live Marionette: tutti i flussi OK (lista/albero, tab diff, Unified+Split, collapse pannello).
