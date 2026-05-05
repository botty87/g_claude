import '../../domain/entities/dictation_partial.dart';

abstract interface class DictationDataSource {
  Future<bool> initialize();
  Future<bool> hasPermission();
  Stream<DictationPartial> get partials;
  Future<void> startListening({required String localeId});
  Future<void> stop();
  Future<void> cancel();
}
