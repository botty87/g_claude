# g_claude

GUI desktop per Claude Code. Flutter macOS first.

Ispirato all'architettura di [clui-cc](https://github.com/anthropics/clui-cc): l'app
lancia il binario `claude -p` come subprocess per ogni sessione, normalizza lo stream
NDJSON in eventi consumabili dalla UI, ed espone un HTTP server locale che Claude Code
interroga via PreToolUse hooks per chiedere l'approvazione dell'utente sui tool calls.

> **Stato**: scaffolding. Le feature reali (sessioni, parsing NDJSON, permission server,
> multi-tab) arriveranno nelle prossime sessioni.

## Stack

- Flutter desktop, target primario macOS
- Clean Architecture (`data` / `domain` / `presentation`) per feature
- `flutter_bloc` + `get_it` + `injectable`
- `freezed` + `json_serializable` per modelli immutabili
- `auto_route` per il routing
- `talker_flutter` + `talker_bloc_logger` per il logging
- `Either<L,R>` custom (no `dartz`) per il return dei use case
- `marionette_flutter` per il pilotaggio dell'app via MCP da agenti AI

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Run

```bash
flutter run -d macos
```

L'app stampa un VM Service URI sulla console (es. `ws://127.0.0.1:58375/xxx=/ws`).
Lo si usa per agganciare Marionette MCP (vedi sotto).

## Marionette MCP — pilotare l'app via Claude Code

Il package `marionette_flutter` espone VM Service extensions che permettono ad agenti
MCP (Claude Code, Cursor, Copilot) di interrogare e pilotare l'app durante lo sviluppo:
tap, enter_text, scroll, take_screenshots, hot_reload, get_logs.

**Flusso d'uso:**

1. Avvia l'app in debug:
   ```bash
   flutter run -d macos
   ```
2. Copia il `wsUri` dal log (linea `app.debugPort` o `Debug service listening on...`).
3. In Claude Code, chiedi: *"Connetti Marionette a `ws://127.0.0.1:58375/xxx=/ws`,
   poi fammi uno smoke test della home page (screenshot + lista interactive elements +
   ultimi 50 log)"*.

I log Talker dell'app vengono inoltrati al `LogCollector` di Marionette tramite
`MarionetteLogBridge` (`lib/core/marionette/marionette_log_bridge.dart`), quindi il
tool MCP `get_logs` restituisce sia framework output sia transizioni Bloc, errori
repository, info dei service.

**Solo debug mode.** In release Marionette è completamente tree-shaken (`kDebugMode`
guard in [main.dart](lib/main.dart)).

## Struttura

```
lib/
├── main.dart                              # entry: marionette → window → DI → bloc → runApp
├── app.dart                               # MaterialApp.router + AppTheme + AppRouter
├── core/
│   ├── di/
│   │   ├── di.dart                        # getIt + configureDependencies()
│   │   ├── di.config.dart                 # generato
│   │   └── modules/                       # @module per Talker, BlocObserver, Router
│   ├── error/                             # Failure / Exception + extensions
│   ├── utils/                             # Either<L,R>, UseCase
│   ├── theme/                             # AppTheme light/dark + colors + typography
│   ├── router/                            # @AutoRouterConfig
│   ├── marionette/                        # MarionetteLogBridge (Talker → MCP)
│   └── window/                            # window_manager init
├── features/                              # cresceranno: session, permission, conversation, settings
└── shared/widgets/                        # widget riusabili cross-feature
```
