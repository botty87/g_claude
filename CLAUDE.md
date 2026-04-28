# g_claude — Project Conventions

GUI desktop (macOS-first) per Claude Code. Ogni tab in alto = una cartella aperta = un workspace. Da quel tab si interagisce con un'istanza di `claude` lanciata in quella cartella.

## Stato corrente

Sessione 1 in corso: layout shell + feature `workspace` (apri cartella -> tab + lettura `CLAUDE.md`). No subprocess `claude`, no chat, no explorer tree, no persistenza. Quei pezzi arrivano nelle sessioni successive.

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
- **DI**: `get_it` + `injectable` (annotazioni: `@injectable`, `@LazySingleton`, `@lazySingleton`, `@PostConstruct`, `@factoryParam`)
- **Models**: `freezed` con `freezed_annotation`. State **sealed**. Equality automatica.
- **Routing**: `auto_route` (`@RoutePage`, `RootStackRouter`)
- **Errori**: `Either<L, R>` custom in `core/utils/either.dart`. **No** dartz/fpdart.
- **Failure**: gerarchia in `core/error/failures.dart` (`ValidationFailure`, `NotFoundFailure`, `UnexpectedFailure`, `SubprocessFailure`, ecc.). Nessuna eccezione bubble nel layer presentation.
- **UseCase**: interfaccia in `core/utils/usecase.dart`. Firma standard `Future<Either<Failure, T>> call(...)`. Parametri inline o `*Params extends Equatable`.
- **Logging**: `talker_flutter` + `talker_bloc_logger` (BlocObserver registrato globalmente). Forward to Marionette in debug mode tramite `core/marionette/marionette_log_bridge.dart`.
- **Theme**: Glass Graphite dark M3. Token in `core/theme/` (`AppColors`, `AppTypography`, `AppSpacing`, `AppRadii`). Effetti glass via `shared/widgets/glass/glass_pane.dart`.

## Pattern

**Cubit (stile proloco)**:
```dart
@lazySingleton                                    // o @injectable / @factoryParam
class FooCubit extends Cubit<FooState> {
  FooCubit(this._dep) : super(const FooState.initial());
  final Dependency _dep;

  @PostConstruct()
  Future<void> init() async { /* setup */ }       // opzionale
}
```

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
- No `print` — usa `talker.info`, `talker.error`.
- No commenti narrativi in codice (lascia parlare il nome). Commenti solo per WHY non ovvi.
- No test in fase scaffolding — verranno aggiunti quando logica diventa non triviale (parser NDJSON, permission resolver).
