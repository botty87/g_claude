import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/app_log_session.dart';
import '../../domain/repositories/app_logs_repository.dart';
import '../../domain/usecases/delete_session.dart';
import '../../domain/usecases/watch_log_sessions.dart';

part 'app_logs_cubit.freezed.dart';
part 'app_logs_cubit.state.dart';

@lazySingleton
class AppLogsCubit extends Cubit<AppLogsState> {
  AppLogsCubit(
    this._watchLogSessions,
    this._deleteSession,
    this._repo,
  ) : super(const AppLogsState());

  final WatchLogSessions _watchLogSessions;
  final DeleteSession _deleteSession;
  final AppLogsRepository _repo;

  StreamSubscription<List<AppLogSession>>? _sub;

  @PostConstruct()
  void init() {
    _sub = _watchLogSessions().listen((sessions) {
      final currentId = _repo.currentSessionId;
      int? selected = state.selectedSessionId;
      // Auto-select the current (in-progress) session on first load.
      if (selected == null && currentId != null) {
        selected = currentId;
      }
      emit(state.copyWith(
        sessions: sessions,
        loading: false,
        selectedSessionId: selected,
      ));
    });
  }

  void selectSession(int id) {
    emit(state.copyWith(selectedSessionId: id));
  }

  void clearSelection() {
    emit(state.copyWith(selectedSessionId: null));
  }

  Future<void> deleteSession(int id) async {
    final result = await _deleteSession(sessionId: id);
    result.fold((_) => null, (_) {
      if (state.selectedSessionId == id) {
        emit(state.copyWith(selectedSessionId: null));
      }
    });
  }

  Future<void> deleteAll() async {
    await _repo.deleteAll();
    emit(state.copyWith(sessions: const [], selectedSessionId: null));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
