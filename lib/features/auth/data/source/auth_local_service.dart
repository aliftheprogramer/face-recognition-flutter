import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class AuthLocalService {
  static const _kFirstRunDone = 'first_run_done';
  // Keep legacy key but also write to common keys used by interceptors.
  static const _kAuthToken = 'auth_token';
  static const _kToken = 'token';
  static const _kAccessToken = 'access_token';

  final SharedPreferences _prefs;
  final _logger = Logger();

  AuthLocalService(this._prefs);

  Future<bool> isFirstRun() async {
    final isFirst = !(_prefs.getBool(_kFirstRunDone) ?? false);
    _logger.d('🔍 isFirstRun: $isFirst');
    return isFirst;
  }

  Future<void> setFirstRunComplete() async {
    try {
      await _prefs.setBool(_kFirstRunDone, true);
      _logger.i('✅ First run marked as complete');
    } catch (e) {
      _logger.e('❌ Error setting first run complete: $e');
      rethrow;
    }
  }

  /// Save token under multiple keys for compatibility with network layer.
  Future<void> saveToken(String token) async {
    try {
      _logger.i('💾 Saving token to SharedPreferences...');
      _logger.d(
        '📝 Token value: ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
      );

      // Save to all three keys for maximum compatibility
      final success1 = await _prefs.setString(_kAuthToken, token);
      final success2 = await _prefs.setString(_kToken, token);
      final success3 = await _prefs.setString(_kAccessToken, token);

      _logger.d(
        '💾 Save results - auth_token: $success1, token: $success2, access_token: $success3',
      );

      // Verify token was saved
      final savedToken = _prefs.getString(_kToken);
      if (savedToken == token) {
        _logger.i('✅ Token berhasil disimpan dan diverifikasi');
      } else {
        _logger.e(
          '❌ Token gagal disimpan! Saved: $savedToken vs Original: ${token.substring(0, 20)}...',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('❌ Error saving token: $e');
      _logger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  String? getToken() {
    try {
      _logger.d('🔍 Getting token from SharedPreferences...');

      // Prefer `token` then `access_token` then legacy `auth_token`.
      final t1 = _prefs.getString(_kToken);
      if (t1 != null && t1.isNotEmpty) {
        _logger.i(
          '✅ Token found in \'token\' key: ${t1.substring(0, t1.length > 20 ? 20 : t1.length)}...',
        );
        return t1;
      }

      final t2 = _prefs.getString(_kAccessToken);
      if (t2 != null && t2.isNotEmpty) {
        _logger.i(
          '✅ Token found in \'access_token\' key: ${t2.substring(0, t2.length > 20 ? 20 : t2.length)}...',
        );
        return t2;
      }

      final t3 = _prefs.getString(_kAuthToken);
      if (t3 != null && t3.isNotEmpty) {
        _logger.i(
          '✅ Token found in \'auth_token\' key: ${t3.substring(0, t3.length > 20 ? 20 : t3.length)}...',
        );
        return t3;
      }

      _logger.w('⚠️ No token found in SharedPreferences');
      return null;
    } catch (e) {
      _logger.e('❌ Error getting token: $e');
      return null;
    }
  }

  Future<void> clearToken() async {
    try {
      _logger.i('🗑️ Clearing all tokens from SharedPreferences...');

      await _prefs.remove(_kAuthToken);
      await _prefs.remove(_kToken);
      await _prefs.remove(_kAccessToken);

      // Verify tokens were cleared
      final hasToken = _prefs.getString(_kToken) != null;
      if (!hasToken) {
        _logger.i('✅ All tokens berhasil dihapus');
      } else {
        _logger.w('⚠️ Token mungkin masih ada setelah clear');
      }
    } catch (e) {
      _logger.e('❌ Error clearing tokens: $e');
      rethrow;
    }
  }

  static const _kCurrentUser = 'current_user';

  /// Save current user object as JSON string
  Future<void> saveUserJson(String json) async {
    try {
      _logger.i('💾 Saving user JSON to SharedPreferences...');
      _logger.d(
        '📝 User JSON preview: ${json.substring(0, json.length > 100 ? 100 : json.length)}...',
      );

      final success = await _prefs.setString(_kCurrentUser, json);

      if (success) {
        _logger.i('✅ User JSON berhasil disimpan');
      } else {
        _logger.e('❌ User JSON gagal disimpan');
      }
    } catch (e, stackTrace) {
      _logger.e('❌ Error saving user JSON: $e');
      _logger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Return stored JSON string representing current user, or null
  String? getUserJson() {
    try {
      _logger.d('🔍 Getting user JSON from SharedPreferences...');

      final json = _prefs.getString(_kCurrentUser);

      if (json != null && json.isNotEmpty) {
        _logger.i(
          '✅ User JSON found: ${json.substring(0, json.length > 100 ? 100 : json.length)}...',
        );
        return json;
      } else {
        _logger.w('⚠️ No user JSON found in SharedPreferences');
        return null;
      }
    } catch (e) {
      _logger.e('❌ Error getting user JSON: $e');
      return null;
    }
  }

  Future<void> clearUser() async {
    try {
      _logger.i('🗑️ Clearing user JSON from SharedPreferences...');

      await _prefs.remove(_kCurrentUser);

      // Verify user was cleared
      final hasUser = _prefs.getString(_kCurrentUser) != null;
      if (!hasUser) {
        _logger.i('✅ User JSON berhasil dihapus');
      } else {
        _logger.w('⚠️ User JSON mungkin masih ada setelah clear');
      }
    } catch (e) {
      _logger.e('❌ Error clearing user JSON: $e');
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    final hasToken = getToken() != null;
    _logger.d('🔍 isLoggedIn check: $hasToken');
    return hasToken;
  }
}
