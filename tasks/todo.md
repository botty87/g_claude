# Restyle TURN 10 + 11 — controllo adattivo worktree·sessione (Home definitiva)

Design: `Clyde Restyle.dc.html` TURN 10 (comportamento dropdown) + TURN 11 (layout). Costruisce sopra il lavoro 8c non ancora committato (riusa palette ⌘P + riga tab file).

## Decisioni utente
- Le **tab sessioni orizzontali spariscono** → sostituite da un unico **controllo breadcrumb** `[avatar] branch · sessione ●▾` sempre a vista (evoluzione del `_WorktreeChip`).
- Dropdown adattivo: sidebar **espansa** → solo sessioni + hint; sidebar **collassata** → worktree (attivo spuntato) + sessioni.
- Segmented: **resta icon-only** (versione 8c, NON tornare alle label) — scelta utente per compattezza.
- Layout: **riga 1 sempre** (breadcrumb · spacer · segmented icon-only · [Codice] Sbircia · meter · Pronto); **riga 2 solo in Codice** (tab file + ⌘P); Chat/Terminale = 1 riga.

## Task
- [ ] **`session_tab_bar.dart` → rework** in controllo breadcrumb+dropdown (rinomina file/classe → `session_worktree_picker.dart` / `SessionWorktreePicker`, HookWidget). Elimina tab orizzontali + "+". Breadcrumb: avatar tint + branch (mono muted) + "·" + titolo sessione attiva + dot running (sky/pulse) + chevron. Dropdown `MenuAnchor`: [se collassata] sezione WORKTREE (worktree aperti del repo, attivo con check → `openPath`) + divisore; sezione SESSIONI (`tabsList`, dot+titolo, riga attiva evidenziata → `switchTab`) + "＋ Nuova sessione" (`openNewSession`); [se espansa] hint "Cambia worktree dalla sidebar →". Riusa tint/logica worktree del vecchio `_WorktreeChip`. Indicatore aggregato: se una sessione **non-attiva** è busy → pallino `agentRunning` come badge sull'avatar.
- [ ] **`center_pane.dart`**: split `_MergedToolbar` → **riga 1** (`_TopBar`): breadcrumb + `Spacer` + segmented icon-only (`_Segment` invariato, con Tooltip) + [Codice] "Riduci a sbircia" (`demoteToPeek`) + meter + status. **riga 2** (`_CodeTabsBar`, solo `effectiveView==code`): `Expanded` scroll `FileTab` + trigger ⌘P. `CenterPane.Column`: `_TopBar` · `if code: _CodeTabsBar` · `Expanded(switch)`.
- [ ] **L10n**: `claude.worktreePicker.{sessionsHeader,worktreeHeader,changeWorktreeHint}`; riusa `Claude.Terminal.Actions.newSession` per "Nuova sessione" e `WorktreeChip.*` esistenti. Rigenera.
- [ ] **Test**: rework `session_tab_bar_worktree_chip_test.dart` → `session_worktree_picker_test.dart`: breadcrumb mostra sessione attiva; dropdown lista sessioni; espansa=no sezione worktree / collassata=sì; tap sessione→`switchTab`; tap "+"→`openNewSession`; tap worktree→`openPath`. Mantieni verde `quick_open_palette_test.dart`.
- [ ] **Verifica**: `just analyze` + test + Marionette (1 riga in Chat, 2 in Codice; breadcrumb apre dropdown; espansa=solo sessioni, collassata=worktree+sessioni; switch sessione/worktree).

## Riuso da 8c (invariato)
Palette `quick_open_palette.dart`, `FileTab` in riga 2, trigger ⌘P, shortcut ⌘P in `app_shell.dart`, `_Segment` icon-only.

## Review
(da compilare)
