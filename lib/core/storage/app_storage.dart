import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tokens go in secure storage (Keychain/Keystore). Non-sensitive flags
/// (like "has the user seen onboarding") go in plain SharedPreferences —
/// no reason to pay the secure-storage cost for that.
class SecureStorage {
  SecureStorage._();
  static const _storage = FlutterSecureStorage();

  static Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  static Future<String?> read(String key) => _storage.read(key: key);
  static Future<void> delete(String key) => _storage.delete(key: key);
  static Future<void> deleteAll() => _storage.deleteAll();
}

class LocalPrefs {
  LocalPrefs._();

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
