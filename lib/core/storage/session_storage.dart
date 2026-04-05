import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences override not provided');
});

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return SessionStorage(ref.watch(sharedPreferencesProvider));
});

class SessionStorage {
  SessionStorage(this._preferences);

  static const _tokenKey = 'api_token';

  final SharedPreferences _preferences;

  String? readToken() => _preferences.getString(_tokenKey);

  Future<void> saveToken(String token) async {
    await _preferences.setString(_tokenKey, token);
  }

  Future<void> clear() async {
    await _preferences.remove(_tokenKey);
  }
}

