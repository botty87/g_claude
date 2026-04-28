import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class KeyValueStore {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);
  Future<void> remove(String key);
}

@LazySingleton(as: KeyValueStore)
class SharedPreferencesKeyValueStore implements KeyValueStore {
  SharedPreferencesKeyValueStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String?> readString(String key) async => _prefs.getString(key);

  @override
  Future<void> writeString(String key, String value) async {
    final ok = await _prefs.setString(key, value);
    if (!ok) {
      throw StateError('SharedPreferences.setString returned false for key=$key');
    }
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
