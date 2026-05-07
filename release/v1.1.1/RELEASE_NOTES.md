# Clyde v1.1.1

_Released 2026-05-07_

## Highlights

- **Fullscreen chat ripulito**: in modalità a schermo intero (Cmd+B) la barra superiore con tab editor sparisce; selettore workspace e toggle fullscreen migrano dentro l'header di Claude, alla destra di "Pronto", recuperando spazio verticale per la conversazione.
- **Slash palette mid-text**: la palette `/` si apre anche con testo già scritto sulla riga (es. `ciao /fo`), filtra sul token finale, e in caso di nessun match mostra l'elenco completo invece di nascondersi.
- **Input chat più capiente**: maxLines 6 → 15 per comporre messaggi lunghi senza scroll interno serrato.

## Fixes

- `fix(shell)`: `FileTabsBar` collassa a `SizedBox.shrink()` quando `workspaceOpen=false`; nessuna barra fantasma in fullscreen.
- `fix(claude)`: `WorkspaceDropdown` + `WorkspaceToggleButton` rilocati nell'header di Claude in fullscreen; padding-right del header azzerato per allineare il toggle al bordo.
- `fix(shell)`: `WorkspaceToggleButton` reso pubblico e ricostruito su `Hoverable` (feedback hover/tap visibile su superficie scura, prima `IconButton` senza splash percepibile).
- `fix(slash)`: `slashTokenAtEndRegex` matcha il token finale dopo whitespace; nessun match → fallback all'elenco completo (coerente con prefisso vuoto). `_stripSlashPrefix` preserva il testo prima dello slash sui multiline.
- `fix(shell)`: rimossa `GlobalKey _claudePaneKey` da `AppShellPage` per evitare l'assertion di reparenting su `OverlayPortal`; il pane rimonta su Cmd+B ma stato (messages, run, draft) sopravvive in `ClaudeSessionsCubit`.

## Provenance

Bundle recuperato dal branch orfano `fix/multi-issues-batch` (commit `375423a` del 2026-05-06) mai mergiato in main; riapplicato sopra il codebase post-1.1.0 senza regressioni su context meter / compact / terminal.

## Tests

- Suite 249/249 pass; `dart analyze` pulito.
- Test `slash_commands_cubit` aggiornato al nuovo contratto: nessun match → fallback all'elenco completo.

## Install (macOS)

1. Download `Clyde-v1.1.1-macos.zip` da questa release.
2. Unzip; sposta `Clyde.app` in `/Applications`.
3. Rimuovi l'attributo di quarantena (obbligatorio, app non firmata):

   ```bash
   xattr -cr /Applications/Clyde.app
   ```

   Senza questo passo macOS mostra "Clyde is damaged and can't be opened".
4. Lancia normalmente (doppio click).

## Checksum

```
9a01caa09df92f8074f6c4c43ce7af68b44f0fd1403b00a519a4754b844bd0a5  Clyde-v1.1.1-macos.zip
```
