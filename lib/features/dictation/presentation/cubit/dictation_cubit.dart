import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/dictation_mode.dart';
import '../../domain/entities/dictation_partial.dart';
import '../../domain/repositories/dictation_repository.dart';
import '../../domain/usecases/cancel_dictation.dart';
import '../../domain/usecases/start_dictation.dart';
import '../../domain/usecases/stop_dictation.dart';

part 'dictation_cubit.freezed.dart';
part 'dictation_cubit.state.dart';

const _kModePrefKey = 'dictation.v1.mode';

@lazySingleton
class DictationCubit extends Cubit<DictationState> {
  DictationCubit(
    this._repo,
    this._startDictation,
    this._stopDictation,
    this._cancelDictation,
    this._prefs,
    this._talker,
  ) : super(const DictationState.initial(mode: DictationMode.hold));

  final DictationRepository _repo;
  final StartDictation _startDictation;
  final StopDictation _stopDictation;
  final CancelDictation _cancelDictation;
  final SharedPreferences _prefs;
  final Talker _talker;

  StreamSubscription<DictationPartial>? _sub;

  @PostConstruct()
  void init() {
    final mode = _loadMode();
    emit(DictationState.initial(mode: mode));
    _sub = _repo.partials.listen(_onPartial);
    // NOTE: Do NOT eagerly initialize the underlying engine here. On macOS
    // calling SFSpeechRecognizer.requestAuthorization at boot crashes the
    // app when launched from a parent process without microphone TCC grant
    // (e.g. VSCode terminal). Init is deferred to the first start() call.
  }

  DictationMode _loadMode() {
    final raw = _prefs.getString(_kModePrefKey);
    return DictationMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => DictationMode.hold,
    );
  }

  DictationMode get mode => switch (state) {
        DictationStateInitial(:final mode) => mode,
        DictationStateListening(:final mode) => mode,
        DictationStateError(:final mode) => mode,
      };

  Future<void> setMode(DictationMode mode) async {
    await _prefs.setString(_kModePrefKey, mode.name);
    final s = state;
    final next = switch (s) {
      DictationStateInitial() => DictationState.initial(mode: mode),
      DictationStateListening() => s.copyWith(mode: mode),
      DictationStateError() => s.copyWith(mode: mode),
    };
    emit(next);
  }

  bool get isListening => state is DictationStateListening;

  Future<void> start({
    required String workspaceId,
    required String baseText,
    required int baseOffset,
    required String localeId,
  }) async {
    if (isListening) return;
    final m = mode;
    _talker.info('dictation.start workspace=$workspaceId locale=$localeId mode=${m.name}');
    emit(DictationState.listening(
      workspaceId: workspaceId,
      baseText: baseText,
      baseOffset: baseOffset.clamp(0, baseText.length),
      currentPartial: '',
      mode: m,
    ));
    final result = await _startDictation(localeId: localeId);
    result.fold(
      (failure) {
        _talker.error('dictation.start failed: $failure');
        emit(DictationState.error(failure: failure, mode: m));
      },
      (_) {},
    );
  }

  Future<void> stop() async {
    if (!isListening) return;
    final m = mode;
    _talker.info('dictation.stop');
    final result = await _stopDictation();
    result.fold(
      (failure) {
        _talker.error('dictation.stop failed: $failure');
        emit(DictationState.error(failure: failure, mode: m));
      },
      (_) {},
    );
  }

  Future<void> cancel() async {
    final m = mode;
    _talker.info('dictation.cancel');
    await _cancelDictation();
    emit(DictationState.initial(mode: m));
  }

  void _onPartial(DictationPartial partial) {
    final s = state;
    if (s is! DictationStateListening) return;
    if (partial.isFinal) {
      _talker.info('dictation.final length=${partial.text.length}');
      emit(s.copyWith(currentPartial: partial.text));
      emit(DictationState.initial(mode: s.mode));
      return;
    }
    emit(s.copyWith(currentPartial: partial.text));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _cancelDictation();
    return super.close();
  }
}
