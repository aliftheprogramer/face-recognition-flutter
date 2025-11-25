import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalService {
  static const _kFirstRunDone = 'first_run_done';
  // Keep legacy key but also write to common keys used by interceptors.
  static const _kAuthToken = 'auth_token';
  static const _kToken = 'token';
  static const _kAccessToken = 'access_token';

  final SharedPreferences _prefs;

  AuthLocalService(this._prefs);

  Future<bool> isFirstRun() async {
    return !(_prefs.getBool(_kFirstRunDone) ?? false);
  }

  Future<void> setFirstRunComplete() async {
    await _prefs.setBool(_kFirstRunDone, true);
  }

  /// Save token under multiple keys for compatibility with network layer.
  Future<void> saveToken(String token) async {
    await _prefs.setString(_kAuthToken, token);
    await _prefs.setString(_kToken, token);
    await _prefs.setString(_kAccessToken, token);
  }

  String? getToken() {
    // Prefer `token` then `access_token` then legacy `auth_token`.
    final t1 = _prefs.getString(_kToken);
    if (t1 != null && t1.isNotEmpty) return t1;
    final t2 = _prefs.getString(_kAccessToken);
    if (t2 != null && t2.isNotEmpty) return t2;
    final t3 = _prefs.getString(_kAuthToken);
    if (t3 != null && t3.isNotEmpty) return t3;
    return null;
  }

  Future<void> clearToken() async {
    await _prefs.remove(_kAuthToken);
    await _prefs.remove(_kToken);
    await _prefs.remove(_kAccessToken);
  }

  static const _kCurrentUser = 'current_user';

  /// Save current user object as JSON string
  Future<void> saveUserJson(String json) async {
    await _prefs.setString(_kCurrentUser, json);
  }

  /// Return stored JSON string representing current user, or null
  String? getUserJson() {
    return _prefs.getString(_kCurrentUser);
  }

  Future<void> clearUser() async {
    await _prefs.remove(_kCurrentUser);
  }

  Future<bool> isLoggedIn() async {
    return getToken() != null;
  }
}
