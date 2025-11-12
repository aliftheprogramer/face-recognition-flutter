import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalService {
	static const _kFirstRunDone = 'first_run_done';
	static const _kAuthToken = 'auth_token';

	final SharedPreferences _prefs;

	AuthLocalService(this._prefs);

	Future<bool> isFirstRun() async {
		return !(_prefs.getBool(_kFirstRunDone) ?? false);
	}

	Future<void> setFirstRunComplete() async {
		await _prefs.setBool(_kFirstRunDone, true);
	}

	Future<void> saveToken(String token) async {
		await _prefs.setString(_kAuthToken, token);
	}

	String? getToken() {
		final t = _prefs.getString(_kAuthToken);
		if (t == null || t.isEmpty) return null;
		return t;
	}

	Future<void> clearToken() async {
		await _prefs.remove(_kAuthToken);
	}

	Future<bool> isLoggedIn() async {
		return getToken() != null;
	}
}
