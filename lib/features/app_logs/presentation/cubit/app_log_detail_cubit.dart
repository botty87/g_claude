import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/app_log_entry.dart';
import '../../domain/usecases/watch_session_entries.dart';
import 'app_logs_cubit.dart';

part 'app_log_detail_cubit.freezed.dart';
part 'app_log_detail_cubit.state.dart';

@lazySingleton
class AppLogDetailCubit extends Cubit<AppLogDetailState> {
  AppLogDetailCubit(
    this._watchSessionEntries,
    this._appLogsCubit,
  ) : super(const AppLogDetailState());

  final WatchSessionEntries _watchSessionEntries;
  final AppLogsCubit _appLogsCubit;

  StreamSubscription<AppLogsState>? _selectionSub;
  StreamSubscription<List<AppLogEntry>>? _entriesSub;

  @PostConstruct()
  void init() {
    // React to session selection changes in AppLogsCubit.
    _selectionSub = _appLogsCubit.stream.listen((s) {
      if (s.selectedSessionId != state.sessionId) {
        setSession(s.selectedSessionId);
      }
    });
    // Sync with current selection at startup.
    final currentId = _appLogsCubit.state.selectedSessionId;
    if (currentId != null) setSession(currentId);
  }

  void setSession(int? id) {
    _entriesSub?.cancel();
    _entriesSub = null;

    if (id == null) {
      emit(state.copyWith(
        sessionId: null,
        entries: const [],
        loading: false,
      ));
      return;
    }

    emit(state.copyWith(sessionId: id, loading: true, entries: const []));
    _subscribeEntries(id);
  }

  void setLevelFilter(Set<AppLogLevel> levels) {
    emit(state.copyWith(levelFilter: levels));
    _resubscribe();
  }

  void setSearch(String search) {
    emit(state.copyWith(search: search));
    _resubscribe();
  }

  void _resubscribe() {
    final id = state.sessionId;
    if (id == null) return;
    _entriesSub?.cancel();
    _entriesSub = null;
    _subscribeEntries(id);
  }

  void _subscribeEntries(int sessionId) {
    _entriesSub = _watchSessionEntries(
      sessionId: sessionId,
      levels: state.levelFilter,
      search: state.search.trim().isEmpty ? null : state.search,
    ).listen((entries) {
      emit(state.copyWith(entries: entries, loading: false));
    });
  }

  @override
  Future<void> close() async {
    await _selectionSub?.cancel();
    await _entriesSub?.cancel();
    return super.close();
  }
}
