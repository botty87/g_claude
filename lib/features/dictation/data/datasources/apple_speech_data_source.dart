import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:talker_flutter/talker_flutter.dart';

import '../../domain/entities/dictation_partial.dart';
import 'dictation_data_source.dart';

@LazySingleton(as: DictationDataSource)
class AppleSpeechDataSource implements DictationDataSource {
  AppleSpeechDataSource(this._talker);

  final Talker _talker;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final StreamController<DictationPartial> _controller =
      StreamController<DictationPartial>.broadcast();

  bool _initialized = false;

  @override
  Stream<DictationPartial> get partials => _controller.stream;

  @override
  Future<bool> initialize() async {
    if (_initialized) return _speech.isAvailable;
    _initialized = await _speech.initialize(
      onStatus: (status) => _talker.debug('dictation.status: $status'),
      onError: (err) => _talker.error('dictation.error: ${err.errorMsg}'),
      debugLogging: false,
    );
    return _initialized;
  }

  @override
  Future<bool> hasPermission() async {
    if (!_initialized) {
      await initialize();
    }
    return _speech.hasPermission;
  }

  @override
  Future<void> startListening({required String localeId}) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) {
        throw StateError('speech_to_text not available');
      }
    }
    await _speech.listen(
      onResult: (result) {
        _controller.add(
          DictationPartial(
            text: result.recognizedWords,
            isFinal: result.finalResult,
          ),
        );
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      ),
      localeId: localeId,
      pauseFor: const Duration(seconds: 15),
      listenFor: const Duration(minutes: 2),
    );
  }

  @override
  Future<void> stop() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  @override
  Future<void> cancel() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }
}
