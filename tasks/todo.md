# Fase 5b — Creazione worktree (`+ Nuovo worktree` per repo)

ClickUp: `86caj99en`. Handoff §55/§58 ("+ Nuovo worktree per repo").

## Obiettivo
Da un gruppo repo nella sidebar, creare un nuovo worktree — o da **branch nuovo**
(`-b`) o da **branch esistente** senza worktree — e aprirlo come workspace.

## Decisioni di prodotto (default sensati, editabili in review)
1. **Due modalità**: (a) *Nuovo branch* — nome + base ref; (b) *Branch esistente* —
   dropdown dei branch locali **senza** worktree già attivo.
2. **Path di default**: parent di un worktree linked esistente (strip del branch
   dal suo path) + `<branch>`. Es. restyle → `.superset/worktrees/g_claude` →
   nuovo `feature/foo` = `.superset/worktrees/g_claude/feature/foo` (sibling).
   Fallback (solo main presente): `dirname(repoRoot)/<branch>`. Sempre editabile +
   folder picker.
3. **No `--force`, no pre-validazione**: si lascia fallire git (dir esistente,
   branch già esistente) e si mostra `GitException → Failure` nella riga errore,
   stesso pattern di `close_worktree_dialog`.
4. **Remote-tracking**: differito. Base ref può essere `origin/x` come startPoint,
   quindi copertura sufficiente per v1.

## Command form (verificati contro layout reale non-bare)
- Nuovo branch: `git -C <repoRoot> worktree add -b <newBranch> <path> <baseRef>`
- Branch esistente: `git -C <repoRoot> worktree add <path> <branch>`
- Lista branch+mapping: `git -C <repoRoot> branch --list --format='%(refname:short)%09%(worktreepath)'`

## Vincolo git critico
`worktree add <path> <branch>` **rifiuta** un branch già checked-out in un altro
worktree → candidati "branch esistente" = branch locali con `worktreepath` vuoto.

## Piano implementativo

### Layer git (data/domain)
- [ ] Entity `GitBranch {String name, String? worktreePath}` (freezed) + `bool get hasWorktree`.
- [ ] `GitWorktreeDataSource.addWorktree(repoRoot, worktreePath, {newBranch, baseRef, checkoutBranch})`.
- [ ] `GitWorktreeDataSource.listBranches(repoRoot)` + static `@visibleForTesting parseBranchList(String)`.
- [ ] `GitRepository.addWorktree(...)` + `listBranches(...)` (iface + impl, mapping Failure).
- [ ] Usecases `AddWorktree`, `ListBranches` (`@injectable`, nomi verbali).

### Logica pura (testabile senza git)
- [ ] `defaultWorktreePath(repoRoot, worktrees, branch)` — pura, strip-branch-suffix + join.
- [ ] Filtro candidati = `branches.where((b) => !b.hasWorktree)`.

### Cubit
- [ ] `createWorktree(repoRoot, {newBranch, baseRef, existingBranch, targetPath})`
      → `Either<Failure,void>`; Right → `_worktreeCache.clear()` + `openPath(targetPath)`.
- [ ] `branchesFor(repoRoot)` per popolare la dialog. Inietta `AddWorktree` + `ListBranches`.

### UI
- [ ] `new_worktree_dialog.dart` (HookWidget): radio nuovo/esistente, TextField nome branch,
      dropdown base ref / dropdown branch esistenti, TextField path (default) + folder picker,
      riga errore, busy. Mirror di `close_worktree_dialog`.
- [ ] `_RepoHeader`: icona `+` (Symbols.add) → `showNewWorktreeDialog(context, repoRoot, worktrees)`.

### l10n
- [ ] `shell.newWorktree.*` + `shell.sidebar.worktrees.addTooltip` (en/it) → `just gen-l10n`.

### Test (policy CLAUDE.md)
- [ ] `parseBranchList` — parser puro, fixture reale.
- [ ] `defaultWorktreePath` — linked esistente / solo main / branch con slash.
- [ ] `git_repository_impl` — addWorktree/listBranches → Failure mapping.
- [ ] `workspaces_cubit` — createWorktree: Right→openPath, Left→no open.
- [ ] `new_worktree_dialog` — widget test consolidato: routing modalità + errore tiene aperta.

### Chiusura
- [ ] `just check` verde, `flutter test` verde.
- [ ] Verifica live Marionette (crea worktree → tab + riga sidebar).
- [ ] Commit (attende approvazione), aggiorna ClickUp `86caj99en`.

## Note
- Layout reale g_claude NON è bare: main = repoRoot, restyle = linked worktree.
- Sync a origin/main: FATTO (fast-forward 949aabc).

## Add-on stessa fase (richiesta 2026-07-03)

### Chip worktree (`_WorktreeChip` in `session_tab_bar.dart`)
- [x] Visibile **solo** con sidebar collassata (gate nel parent `SessionTabBar`).
- [x] Lista **solo worktree aperti** (rimosso loop branch-senza-worktree).
- [x] Test aggiornato + verifica live Marionette OK.

### Animazione pannello sinistro (`WorkspaceSidebar`)
- [x] `AnimatedContainer` (width+color) + `AnimatedSwitcher` + `_PinnedWidth`/`ClipRect`. NO Expandable.
- [x] Verifica live Marionette: nessun overflow (0 errori nel log, entrambe le direzioni).

## Restyle dialog (TURN 6 del design claude — richiesta 2026-07-03)
- [x] `glass_dialog.dart`: shell condiviso Glass Graphite (panel #1F1F27 r16 glassBorder + scrim,
      header icona-tint, pill button primary/destructive, segmented, option card + badge, field
      label-uppercase + field scuro). Tutti su token AppColors/AppTypography.
- [x] `close_worktree_dialog`: opzioni = card selezionabili con badge SICURO/DISTRUTTIVO,
      header icona warning + chip branch, Conferma rossa (errorContainer) se distruttivo. Key invariate.
- [x] `new_worktree_dialog`: header icona + segmented + campi label-uppercase + POSIZIONE con Sfoglia.
      Key invariate. NB: il design TURN 6c propone "Apri esistente (cartella)" come 2° modo; io ho
      mantenuto il "Branch esistente" (checkout) di 5b — divergenza funzionale segnalata all'utente.
- [x] Bug trovato in verifica: `git worktree add` andava in timeout a 3s (checkout completo) →
      falso errore mentre git creava il worktree. Fix: `_addTimeout` 120s dedicato.

## Review
- Layer git (entity GitBranch, datasource addWorktree/listBranches+parseBranchList, repo, usecase): OK, testato.
- Logica pura `defaultWorktreePath`: OK, testata (linked/main/bare/slash).
- Cubit createWorktree/branchesFor: OK, testato (Right→open, Left→no open).
- UI 5b + restyle: verificati live via Marionette (creazione end-to-end + dialog restyle).
- Add-on (chip solo-collassata, chip solo-aperti, animazione sidebar): verificati live.
- `just analyze` + `just format-check` puliti. `flutter test`: 312/312 verdi.
- Worktree di test `test/wt-verify` creato e rimosso durante la verifica (repo pulito).
- NON committato: attende approvazione utente.

## Correzioni dialog (round feedback 2026-07-04)
- [x] Cursore a manina + feedback hover su tutti gli elementi cliccabili (segmented,
      card opzioni, pill button, ×, dropdown, browse, switch) via `Hoverable`.
- [x] BASE: rimosso il letterale "HEAD" → elenca/propone nomi branch reali; default =
      branch del worktree principale (`main`), fix del vecchio comportamento.
- [x] POSIZIONE: campo editabile + **precompilato subito**, base = `<repoRoot>/.worktrees/<branch>`
      (scelta utente "dentro il repo"). `defaultWorktreePath` semplificata (no più param worktrees).
      NB: `.worktrees/` va aggiunto a `.gitignore` (non toccato da me).
- [x] Switch "Apri il worktree dopo la creazione" (default ON) → `createWorktree(openAfter:)`;
      `GlassSwitch` compatto (36×20, design 6b) al posto del Material Switch.
- [x] Branch elenco = solo LOCALI (`git branch --list`); remote-tracking non inclusi (follow-up).
- [x] Tutto verificato live (BASE=main, POSIZIONE precompilata, switch, path `.worktrees/<branch>`); 312 test verdi.

## 2ª tab "Apri esistente" (round feedback 2026-07-04, design 6c)
- [x] Sostituito "Branch esistente" (checkout) con **"Apri esistente"**: folder picker/editabile che
      ispeziona la cartella e mostra una card (cartella semplice / repository / worktree) con
      Repository/Branch/Stato (modifiche non committate). Confirm → `openPath`.
- [x] Nuova pipeline `inspect`: entity `GitFolderInspection`, datasource `inspect` (worktree-vs-repo
      via `--git-dir`, dirty count via `status --porcelain`), repo/usecase `InspectFolder`, cubit `inspectFolder`.
- [x] Switch "Apri dopo creazione" mostrato SOLO in "Nuovo branch" (aprendo un esistente non si crea).
- [x] Confirm dinamico: "Crea" (nuovo) / "Apri worktree" (esistente). Verificato live (card "Repository
      Git rilevato" + main + 3 modifiche). 314 test verdi, analyze/format puliti.
