# Clyde v1.1.0

_Released 2026-05-07_

## Highlights

- **Embedded PTY terminal** per workspace, con xterm + zsh, scrollback, copy/paste con bracketed-paste, restart hot-respawn.
- **Context window meter** in chat header: ring circolare con percentuale + tooltip dettagliato (input / cache read / cache create / output / limite).
- **Slash commands trasparenti**: `/compact` riassume la conversazione e la inietta come bootstrap del prossimo turno; `/clear` resetta la sessione client-side. Entrambe le commands funzionano end-to-end senza richiedere il CLI interattivo di `claude`.

## New features

- `feat(terminal)`: PTY terminal pane (xterm 4.0 + flutter_pty), session per workspace, restart con incarnation counter, debounce 60ms su SIGWINCH, kill SIGTERM→SIGKILL graceful via helper condiviso.
- `feat(claude)`: context window usage tracking, ring meter nel header con tooltip dettagliato.
- `feat(claude)`: `/compact` e `/clear` come slash command trasparenti, intercettati lato client.

## Fixes & hardening

- Compact session: race su `_runningWorkspaceId` chiusa, `_stopRun` awaited, failure logic robusta a late `onError`, bootstrap injection sopravvive a fail sincrono, dartdoc semantico su `contextTokens`.
- Terminal: race in `_onWorkspacesChanged` chiusa, eventi su broadcast controller chiuso protetti, overlay box catturato sincrono prima di `await showMenu`.
- Window: `minimumSize` ridotto a 500×400 con `center: true` ripristinato.
- macOS: tmp dir creata in modo idempotente prima di `screencapture` (fix dopo bundle rename).

## Refactor

- `lib/core/process/graceful_kill.dart` estratto, riusato da Claude (`stop()`) e Terminal (`_killSession()`).
- `PtySessionEvent` ora `@freezed sealed`; `TerminalRunStatus` spostato in `domain/entities/`.
- Glass Graphite ANSI theme estratto in `core/theme/terminal_theme.dart`.
- Header context meter: 6 `context.select` granulari → 1 record select (rebuild equivalente, codice più leggibile).

## Tooling & release

- `just release-publish` ora pusha `main + tag` atomicamente (single ref-update transaction); `release-push` usa `--follow-tags`.
- `just package-release` warna su `prev_tag` mancante per release non iniziali.

## Tests

- 20 nuovi test per la feature Terminal (cubit state machine + datasource subset).
- Test smoke negativo `pump_app_test.dart` ripristinato.
- Suite totale: 249/249 pass; `dart analyze` pulito.

## Install (macOS)

1. Download `Clyde-v1.1.0-macos.zip` da questa release.
2. Unzip; sposta `Clyde.app` in `/Applications`.
3. Rimuovi l'attributo di quarantena (obbligatorio, app non firmata):

   ```bash
   xattr -cr /Applications/Clyde.app
   ```

   Senza questo passo macOS mostra "Clyde is damaged and can't be opened".
4. Lancia normalmente (doppio click).

## Checksum

```
6cfdfdf79934a3b9e2603d11563784def45e0d96449c742e63f5031880b8961e  Clyde-v1.1.0-macos.zip
```
