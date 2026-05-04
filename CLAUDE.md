# g_claude — Project Conventions

GUI desktop (macOS-first) per Claude Code. Ogni tab in alto = una cartella aperta = un workspace. Da quel tab si interagisce con un'istanza di `claude` lanciata in quella cartella.

## Stato corrente

App funzionale end-to-end. Feature attive:

- **workspace**: multi-cartella con tab in alto, lettura `CLAUDE.md`, persistenza `SharedPreferences` (`workspaces.v1`), file watcher per cancellazioni esterne.
- **shell**: layout desktop con activity bar (left), side panel collassabile, split editor/chat (`multi_split_view`). Shortcut Cmd+B (toggle workspace), Cmd+W (close tab).
- **explorer**: tree view con watcher debounced (250ms), reveal-in-tree per file attivo, prewarm su restore.
- **editor**: tab multiple per workspace, viewer `re_editor` + `re_highlight`, drag & drop (`desktop_drop`), persistenza (`tabs.v1`).
- **claude**: subprocess `claude -p --output-format stream-json` per workspace. Parsing NDJSON in `ClaudeEvent` sealed (sessionInit, textChunk, toolCall, toolResult, permissionRequest, askUserQuestion, sessionDead, rateLimit, ecc.). Streaming testo con flush 16ms. Settings scritte in `~/.claude/settings.json`. History JSONL in `~/.claude/projects/{cwd-encoded}/{sessionid}.jsonl` con list/search/resume/export/delete. MCP toggle + auth per workspace. **AskUserQuestion interattivo disabilitato** (flag `askUserQuestionInteractiveEnabled = false`: upstream CLI non aspetta `tool_result`).
- **PermissionServer** (Shelf, localhost porta effimera): risolve permission mode (default/plan/acceptEdits/bypassPermissions) o emette `ClaudeMessage.permissionRequest` con UI card; risposta tramite `answerPermission` + `Completer<PermissionDecision>`.
- **slash_commands**: palette nel input chat, comandi file-based (CLAUDE.md) + skill-based (da `sessionInit`), filtro live.

Persistenza: `SharedPreferences` per workspace, tab editor, settings sessione, sessione attiva. Cronologia chat: JSONL on disk (`~/.claude/projects/`). `drift` attivo per due DB SQLite in `getApplicationSupportDirectory()`: `g_claude_sessions.sqlite` (indice cronologia chat con FTS5) e `g_claude_app_logs.sqlite` (log Talker per sessione applicazione).

- **app_logs**: subscribe a `talker.stream` via `TalkerLogRecorder` (batch flush 500ms), persiste ogni evento in `LogEntries` legato a `AppSessions` (creata al boot, chiusa via `windowManager` close listener). `FlutterError.onError` + `PlatformDispatcher.onError` + `runZonedGuarded(runApp)` redirigono eccezioni Flutter/async/uncaught a Talker. Retention 30 giorni. UI nella activity bar (entry "Logs") con filtro per livello.

Bootstrap ([lib/main.dart](lib/main.dart)): Marionette (debug) → EasyLocalization + window + DI in parallelo → `MarionetteLogBridge` → restore `WorkspacesCubit` poi `FileTabsCubit` (orphan filter) → `Bloc.observer` → prewarm tab persistite (4 worker concorrenti) → `runApp`. Estensioni Marionette custom: `openWorkspace`, `closeWorkspace`, `setActiveWorkspace`.

Cubit globali (in [lib/app.dart](lib/app.dart)): `WorkspacesCubit`, `ShellCubit`, `ExplorerCubit`, `FileTabsCubit`, `ClaudeSessionsCubit`, `ChatHistoryCubit`. Routing `auto_route` con singola route `AppShellRoute`.

Differito: tray icon + global hotkey (deps presenti), markdown rendering chat (`flutter_markdown` dep presente).

## Architettura

**Clean Architecture per feature**:
```
features/<name>/
├── data/           datasources, models (freezed), repositories impl
├── domain/         entities (freezed), repositories (interfaces), usecases
└── presentation/   cubit (+ *.state.dart), widgets, pages
```

Feature **puramente presentation** (es. `shell`) hanno solo `presentation/`.

## Stack

- **State management**: `flutter_bloc` con **Cubit** (no Bloc events boilerplate)
- **Widget locale state**: `flutter_hooks` (`HookWidget` + `useState` / `useEffect` / `useMemoized` / `useTextEditingController` / `useScrollController` / `useFocusNode` / `useIsMounted` ecc.). **No `StatefulWidget`** salvo casi rari in cui un hook non basta (annotare il perche').
- **DI**: `get_it` + `injectable` (annotazioni: `@injectable`, `@LazySingleton`, `@lazySingleton`, `@PostConstruct`, `@factoryParam`)
- **Models**: `freezed` con `freezed_annotation`. State **sealed**. Equality automatica.
- **Routing**: `auto_route` (`@RoutePage`, `RootStackRouter`)
- **Errori**: `Either<L, R>` custom in `core/utils/either.dart`. **No** dartz/fpdart.
- **Failure**: gerarchia in `core/error/failures.dart` (`ValidationFailure`, `NotFoundFailure`, `UnexpectedFailure`, `SubprocessFailure`, ecc.). Nessuna eccezione bubble nel layer presentation.
- **UseCase**: interfaccia in `core/utils/usecase.dart`. Firma standard `Future<Either<Failure, T>> call(...)`. Parametri inline o `*Params extends Equatable`.
- **Logging**: `talker_flutter` + `talker_bloc_logger` (BlocObserver registrato globalmente). Forward to Marionette in debug mode tramite `core/marionette/marionette_log_bridge.dart`.
- **Theme**: Glass Graphite dark M3. Token in `core/theme/` (`AppColors`, `AppTypography`, `AppSpacing`, `AppRadii`). Effetti glass via `shared/widgets/glass/glass_pane.dart`.
- **Localization**: `easy_localization` con JSON in `assets/translations/{en,it}.json`. Init in `main.dart` (`EasyLocalization.ensureInitialized()` + wrap `App` in `EasyLocalization`). Lingue supportate: `en` (fallback), `it`. Usa `useOnlyLangCode: true` (no varianti regionali). Gerarchia chiavi: `<feature>.<area>.<key>` es. `workspace.emptyState.openFolder`.
  - **API type-safe `Locales`**: accesso via classe generata esportata da `lib/core/l10n/l10n.dart`. Esempio: `Locales.Sessions.Preview.deleteConfirmCancel` (chiave assente → errore di compile, non testo letterale a runtime). Per chiavi con placeholder `{name}`: `Locales.Sessions.Preview.exportDone(path: result)`. Parametri sempre `String` (interpola: `count: '$n'`).
  - **Workflow**: dopo aver aggiunto chiavi nei JSON, esegui `dart run lib/core/l10n/tool/l10n_generate.dart`. Lo script rigenera `lib/core/l10n/locale_keys.g.dart` (chiavi piatte da easy_localization) e `lib/core/l10n/locales.g.dart` (wrapper annidato). Entrambi vanno committati.
  - **Vietato `'foo.bar'.tr()` su literal**: stringly-typed, niente compile-time check. Usa sempre `Locales.X.y`. Eccezione consentita: chiavi costruite dinamicamente da enum (es. `enum.labelKey.tr()` dove `labelKey` è una `String` field).
  - **Convenzione naming**: gruppi nested PascalCase (`Locales.Sessions.List`), foglie camelCase (`Locales.Sessions.List.headerLabel`). Keyword Dart riservate (`default`, `class`, ecc.) → suffix `$` automatico.
  - Eccezioni: log Talker (dev-facing, sempre EN), nomi tecnici/brand (es. "Claude Code GUI" in `MaterialApp.title`).

## Pattern

**Cubit (stile proloco)**:
```dart
@lazySingleton                                    // app-global (default)
class FooCubit extends Cubit<FooState> {
  FooCubit(this._dep) : super(const FooState.initial());
  final Dependency _dep;

  @PostConstruct()
  Future<void> init() async { /* setup */ }       // opzionale
}
```

**Cubit DI — quale annotazione usare**:
- `@lazySingleton` (default): cubit con stato app-global che deve sopravvivere a cambi di route, hot reload, rebuild widget. Esempi: `WorkspacesCubit`, `ShellCubit`, `FileTabsCubit`, `ExplorerCubit`. Anche cubit che si registrano allo stream di altri cubit in `@PostConstruct` **devono** essere singleton (factory perderebbe stato e leak StreamSubscription).
- `@injectable` (factory): solo cubit scoped a una page/route, creati e distrutti col widget owner (via `BlocProvider(create: () => getIt<FooCubit>())`). Adatto a flussi isolati (wizard, form modal) dove serve istanza fresca ad ogni apertura.
- `@factoryParam`: factory con parametri runtime non risolvibili da DI (es. id entita').

**HookWidget**:
```dart
class FooView extends HookWidget {
  const FooView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final query = useState('');

    useEffect(() {
      void listener() => query.value = controller.text;
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    return TextField(controller: controller);
  }
}
```
Niente `dispose` manuale: gli hook gestiscono il lifecycle. Per dipendenze su props, usa la dep-list di `useEffect` (es. `[widget.path]`).

State in file separato `foo_cubit.state.dart`:
```dart
@freezed
sealed class FooState with _$FooState {
  const factory FooState.initial() = FooStateInitial;
  const factory FooState.loaded({required Foo data}) = FooStateLoaded;
  const factory FooState.error({required Failure failure}) = FooStateError;
}
```

**Repository**:
```dart
@LazySingleton(as: FooRepository)
class FooRepositoryImpl implements FooRepository {
  FooRepositoryImpl(this._ds);
  final FooDataSource _ds;

  @override
  Future<Either<Failure, Foo>> doSomething(...) async {
    try {
      final result = await _ds.call(...);
      return Right(result);
    } on FooException catch (e) {
      return Left(SomeFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('$e'));
    }
  }
}
```

**UseCase** (parametri inline preferiti per arity ≤ 2):
```dart
@injectable
class OpenWorkspace {
  OpenWorkspace(this._repo);
  final WorkspaceRepository _repo;

  Future<Either<Failure, Workspace>> call({required String path}) =>
    _repo.openWorkspace(path: path);
}
```

## Naming

- File: **snake_case** (`workspace_repository_impl.dart`, `workspaces_cubit.state.dart`)
- Classi: **PascalCase**
- Suffissi:
  - `*Impl` per implementazioni di interfacce
  - `*DataSource` (no `*Datasource`)
  - **NO** suffix `*UseCase` — il nome del use case e' verbale (`OpenWorkspace`, `LoadClaudeMd`)
  - `*Cubit` / `*State`
  - `*Repository` (interface) / `*RepositoryImpl` (impl)
- File state: `foo_cubit.state.dart` (non `foo_state.dart`)

## Import

- Cross-package / external: `package:`
- Same feature: relativi (`../../../core/...`)
- Mai mischiare nei file (segui il piu' usato nel file vicino)

## Build

- Codegen: `dart run build_runner build --delete-conflicting-outputs`
- Run: `flutter run -d macos`
- Analyze: `dart analyze` o `mcp__dart__analyze_files`

## DI registrazione

Nuovi `@injectable` / `@LazySingleton` / `@lazySingleton` vengono raccolti automaticamente da `configureDependencies()`. Nessun edit manuale a `di.config.dart`. Per dipendenze esterne (es. `Talker`) usare `@module abstract class XxxModule` in `core/di/modules/`.

## Marionette / MCP

App in debug espone Marionette (`MarionetteBinding`). I log Talker sono inoltrati al PrintLogCollector. Tool MCP per ispezionare/pilotare:
- `mcp__marionette__connect`, `get_interactive_elements`, `tap`, `enter_text`, `take_screenshots`, `get_logs`, `hot_reload`
- `mcp__dart__launch_app`, `analyze_files`, `hot_reload`, `pub`, `pub_dev_search`

Widget interattivi devono avere `ValueKey<String>` quando serve test/automation.

## Cosa NON fare

- No singleton globali fuori da `getIt`. No state condivisi via static.
- No `setState` per state cross-widget — usa Cubit.
- No hardcoded string list per cose dinamiche (vedi vecchia `OPEN EDITORS` rimossa).
- No stringhe UI hardcoded — sempre via `Locales.X.y` (vedi sezione Localization). Aggiungere chiave a entrambi `en.json` e `it.json` insieme, poi rigenerare con `dart run lib/core/l10n/tool/l10n_generate.dart`.
- No `print` — usa `talker.info`, `talker.error`.
- No commenti narrativi in codice (lascia parlare il nome). Commenti solo per WHY non ovvi.
- No test in fase scaffolding — verranno aggiunti quando logica diventa non triviale (parser NDJSON, permission resolver).
- No mirror locale di stato cubit. Mai `useState<T>` / `ValueNotifier` per stato già nel cubit (vedi sezione "Lettura stato cubit"). Solo controller UI puri (`useTextEditingController`, `useFocusNode`, `useScrollController`) o stato strettamente effimero locale (hover, expanded toggle).

## Lettura stato cubit (single source of truth + selettori granulari)

**Regola 1 — single source of truth.** Lo stato di dominio vive nel cubit. La UI non lo duplica: legge sempre via `context.select` / `BlocBuilder` / `BlocSelector`. Mai un `useState`/`ValueNotifier` locale che mirroreggi un campo del cubit.

**Regola 2 — selettori granulari, no oggetto-wrapper.** Mai selezionare l'intero `SessionData` / `WorkspaceData` / oggetto stato per poi accederne ai campi. Ogni campo che serve al widget = un `context.select` separato che ritorna il **minimo tipo possibile** (enum, scalare, lista, derivato booleano). Così il widget rebuilda solo quando cambia *quel* campo.

```dart
// SBAGLIATO — qualunque mutazione della session forza rebuild
final session = context.select<ClaudeSessionsCubit, ClaudeSessionData?>(
  (c) => c.state.sessionFor(id),
);
final isBusy = session?.runStatus == ClaudeRunStatus.running;

// CORRETTO — rebuild solo quando il singolo campo cambia
final runStatus = context.select<ClaudeSessionsCubit, ClaudeRunStatus>(
  (c) => c.state.sessions[id]?.runStatus ?? ClaudeRunStatus.idle,
);
final hasMessages = context.select<ClaudeSessionsCubit, bool>(
  (c) => (c.state.sessions[id]?.messages.isNotEmpty) ?? false,
);
```

**Regola 3 — passa `workspaceId` (o id), non l'oggetto stato.** Ogni widget legge il proprio sotto-stato direttamente dal cubit. Non passare `session: ClaudeSessionData` come prop: forza il parent a selezionare l'intero oggetto e propaga i rebuild.

**Regola 4 — callback leggono live.** Dentro `onPressed`, `onDragDone`, `controller.addListener` (registrato in `useEffect` con deps stabili) e simili long-lived listener, **non** chiudere su variabili locali di build che rappresentano stato cubit. Leggi live: `cubit.state.sessions[id]?.X`. Variabili da `context.select` catturate dal closure restano stale fino al rebuild → bug di sovrascrittura.

**Regola 5 — uguaglianza per evitare rebuild inutili.** `context.select` rebuilda quando il valore selezionato cambia per `==`. Liste/mappe Dart usano identity equality di default: assicurati che il cubit, dove possibile, preservi la **stessa referenza** quando il contenuto non cambia (es. ritornare `state.X` invariato in `copyWith` se non si tocca quel campo). Se il valore selezionato è derivato (es. `messages.isNotEmpty`), il bool stabile evita rebuild.

**Pattern di esempio canonico:** [claude_terminal_pane.dart](lib/features/claude/presentation/widgets/claude_terminal_pane.dart), [claude_terminal_header.dart](lib/features/claude/presentation/widgets/claude_terminal_header.dart), [queued_prompt_card.dart](lib/features/claude/presentation/widgets/queued_prompt_card.dart), [claude_input_bar.dart](lib/features/claude/presentation/widgets/claude_input_bar.dart).

**Code review checklist:**
1. Ogni `context.select` ritorna un tipo già scalare / lista / bool? Se ritorna un oggetto stato wrapper → split in N selettori.
2. Ogni `useState<T>` con `T` non triviale: lo stato è già nel cubit? Chi lo modifica fuori dal widget? Se sì a entrambe → eliminare hook.
3. Ogni callback registrata in `useEffect` con deps stabili: legge variabili catturate da build? Se sì → leggere live dal cubit.
4. Widget riceve un oggetto stato come prop? Se sì → ricevere solo l'`id` e leggere via `context.select`.
