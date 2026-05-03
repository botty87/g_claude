# Clyde

GUI desktop per Claude Code. Flutter macOS first.

> Internamente il package Dart si chiama ancora `g_claude` (rename non eseguito per evitare invasivita').

L'app lancia il binario `claude -p` come subprocess per ogni sessione di workspace, normalizza lo stream NDJSON in eventi consumabili dalla UI, ed espone un HTTP server locale (Shelf) che Claude Code interroga per chiedere all'utente l'approvazione dei tool calls. Multi-workspace tabbed: ogni cartella aperta = una tab in alto = una sessione `claude` indipendente con il proprio editor di file, file explorer, chat e history.

## Stato

Scaffolding superato. Funzionali:

- ✅ Multi-workspace con tab in alto, persistenza tra restart, lettura `CLAUDE.md`
- ✅ File explorer ad albero con file watcher e reveal-in-tree
- ✅ Editor multi-tab con syntax highlighting (`re_editor` + `re_highlight`), drag & drop, persistenza tab aperte per workspace
- ✅ Chat con subprocess `claude -p`: parsing NDJSON, streaming testo, tool calls, permission cards
- ✅ Permission server HTTP (Shelf) con permission mode (default / plan / acceptEdits / bypassPermissions)
- ✅ History sessioni `~/.claude/projects/{cwd-encoded}/{sessionid}.jsonl` — list, search, resume, export markdown, delete
- ✅ MCP server toggle e auth flow per workspace
- ✅ Slash commands (file-based + skill-based) con suggestion popup
- ✅ Localization en/it type-safe (`Locales.X.y`)
- ✅ Marionette MCP per pilotaggio in debug

In sviluppo / parzialmente disabilitato:

- ⏳ AskUserQuestion interattivo (flag `askUserQuestionInteractiveEnabled = false`: upstream CLI non aspetta `tool_result`)
- 🔮 Tray icon + global hotkeys (dipendenze presenti, integrazione differita)

## Stack

- Flutter desktop, target primario macOS
- Clean Architecture (`data` / `domain` / `presentation`) per feature
- `flutter_bloc` (Cubit) + `flutter_hooks` per state widget locale
- `get_it` + `injectable` per DI
- `freezed` + `json_serializable` per modelli immutabili e state sealed
- `auto_route` per il routing
- `talker_flutter` + `talker_bloc_logger` per il logging
- `Either<L,R>` custom (no `dartz`/`fpdart`) per il return dei use case
- `shelf` + `shelf_router` per il PermissionServer HTTP
- `re_editor` + `re_highlight` per il file viewer
- `multi_split_view` per il layout split editor/chat
- `desktop_drop` per drag & drop file
- `window_manager` / `tray_manager` / `hotkey_manager` per integrazione desktop
- `shared_preferences` per persistenza chiave/valore
- `easy_localization` per i18n (en, it)
- `marionette_flutter` per pilotaggio dell'app via MCP da agenti AI

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Per generare le icone macOS dopo aver modificato i branding asset:

```bash
dart run flutter_launcher_icons
```

Per rigenerare le chiavi di localizzazione type-safe dopo aver modificato `assets/translations/{en,it}.json`:

```bash
dart run lib/core/l10n/tool/l10n_generate.dart
```

## Run

```bash
flutter run -d macos
```

Prerequisito runtime: il binario `claude` deve essere nel `PATH` (Clyde lo risolve via `which claude`). L'app, al primo lancio di una sessione, scrive `~/.claude/settings.json` con l'URL locale del PermissionServer.

## Architettura runtime

```
┌──────────────────────────────────────────────────────────────────┐
│  Clyde (Flutter UI)                                              │
│  ┌────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐    │
│  │ Tabs   │  │ Explorer │  │ Editor   │  │ Chat (Claude)    │    │
│  │ ws bar │  │ tree     │  │ multitab │  │ msg list + input │    │
│  └────────┘  └──────────┘  └──────────┘  └──────────────────┘    │
│                                                  ▲   │           │
│                          stdin (control req,     │   │ stdout    │
│                          tool_result, answer)    │   │ NDJSON    │
└──────────────────────────────────────────────────┼───┼───────────┘
                                                   │   ▼
                                              ┌─────────────┐
                                              │ claude -p   │ subprocess
                                              │ subprocess  │ per workspace
                                              └─────────────┘
                                                   │
                                                   │ HTTP (PreToolUse)
                                                   ▼
                                              ┌─────────────┐
                                              │ Permission  │ Shelf,
                                              │ Server      │ localhost
                                              └─────────────┘
                                                   │
                                                   ▼
                                              UI permission card
```

Ogni workspace ha la propria `ClaudeSession`: model, permission mode, effort, thinking mode, lista MCP server disabilitati. Tutto persistito in `SharedPreferences` per workspace id (= path assoluto normalizzato).

## Persistenza

| Dato                       | Storage                                                                |
|----------------------------|------------------------------------------------------------------------|
| Lista workspace + attivo   | `SharedPreferences` (`workspaces.v1`)                                  |
| Tab editor aperte / attiva | `SharedPreferences` (`tabs.v1`, per workspace)                         |
| Settings sessione          | `SharedPreferences` (`claude.model.*`, `claude.permission.*`, ecc.)    |
| Sessione attiva            | `SharedPreferences` (`claude.activeSession.{workspaceId}`)             |
| Cronologia chat            | JSONL in `~/.claude/projects/{cwd-encoded}/{sessionid}.jsonl`          |

Il package `drift` e' dichiarato in `pubspec.yaml` per uso futuro ma non e' al momento utilizzato.

## Marionette MCP — pilotare l'app via Claude Code

`marionette_flutter` espone VM Service extensions che permettono ad agenti MCP (Claude Code, Cursor, Copilot) di interrogare e pilotare l'app durante lo sviluppo: `tap`, `enter_text`, `scroll`, `take_screenshots`, `hot_reload`, `get_logs`. I log Talker sono inoltrati al `LogCollector` tramite `MarionetteLogBridge` ([lib/core/marionette/marionette_log_bridge.dart](lib/core/marionette/marionette_log_bridge.dart)).

Estensioni custom registrate in [main.dart](lib/main.dart) per testing automatizzato:

- `openWorkspace(path)` — apre un workspace bypassando il file picker nativo
- `closeWorkspace(id)` — chiude il workspace per id (= path assoluto)
- `setActiveWorkspace(id)` — cambia il workspace attivo

**Flusso d'uso:**

1. `flutter run -d macos`
2. Copia il `wsUri` dal log (`Debug service listening on...`)
3. In Claude Code: *"Connetti Marionette a `ws://...`, poi apri il workspace `/path/to/repo` e fammi screenshot"*

**Solo debug mode.** In release Marionette e' tree-shaken (`kDebugMode` guard in [main.dart](lib/main.dart)).

## Struttura

```
lib/
├── main.dart                                  # marionette → window → DI → restore → prewarm → runApp
├── app.dart                                   # MaterialApp.router + MultiBlocProvider (6 cubit globali)
├── core/
│   ├── di/                                    # getIt + configureDependencies + @module
│   ├── error/                                 # Failure sealed (Validation, NotFound, Subprocess, Permission, ...)
│   ├── utils/                                 # Either<L,R>, UseCase, StreamUseCase
│   ├── theme/                                 # Glass Graphite M3 (colors, typography, spacing, radii)
│   ├── router/                                # AutoRoute (single AppShellRoute)
│   ├── persistence/                           # KeyValueStore (SharedPreferences impl)
│   ├── l10n/                                  # easy_localization + Locales.* generato
│   ├── marionette/                            # MarionetteLogBridge (Talker → MCP)
│   └── window/                                # window_manager init
├── features/
│   ├── workspace/                             # multi-cartella, tab in alto, lettura CLAUDE.md
│   ├── shell/                                 # layout: activity bar + side panel + split editor/chat
│   ├── explorer/                              # file tree con watcher, reveal-in-tree
│   ├── editor/                                # multi-tab file viewer (re_editor)
│   ├── claude/                                # subprocess claude -p, NDJSON, PermissionServer, history
│   └── slash_commands/                        # palette comandi (file + skill)
└── shared/widgets/                            # glass pane, componenti riusabili
```

## Convenzioni

Vedi [CLAUDE.md](CLAUDE.md) per pattern Cubit/HookWidget, naming, import, DI, localization workflow e regole di stile.
