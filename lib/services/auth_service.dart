import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // For utf8 encoding
import 'dart:io';
import 'package:path/path.dart' as path;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _hasPasswordKey =
      'app_has_password_v1'; // Added versioning to key
  static const String _passwordHashKey = 'app_password_hash_v1';
  static const String _saltKey = 'app_password_salt_v1';

  Future<bool> isFirstRun({String? customDbPath}) async {
    if (customDbPath != null) {
      final prefsFile =
          File(path.join(customDbPath, 'shared_preferences.json'));
      if (!await prefsFile.exists()) return true;
      try {
        final content = await prefsFile.readAsString();
        final prefs = json.decode(content) as Map<String, dynamic>;
        final value = prefs[_hasPasswordKey];
        if (value == null) return true;
        if (value is bool) return !value;
        if (value is String) {
          final boolValue = value.toLowerCase() == 'true';
          prefs[_hasPasswordKey] = boolValue;
          await prefsFile.writeAsString(json.encode(prefs));
          return !boolValue;
        }
        return true;
      } catch (e) {
        print('Error reading custom prefs: $e');
        return true;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final value = prefs.get(_hasPasswordKey);
    if (value == null) return true;
    if (value is bool) return !value;
    if (value is String) {
      // Handle case where it was stored as a String
      final boolValue = value.toLowerCase() == 'true';
      // Fix the value to be stored as a boolean
      await prefs.setBool(_hasPasswordKey, boolValue);
      return !boolValue;
    }
    // For any other type, consider it a first run
    return true;
  }

  Future<bool> setupPassword(String password, {String? customDbPath}) async {
    if (password.isEmpty) {
      print("AuthService: Password cannot be empty for setup.");
      return false;
    }
    try {
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(password, salt);

      if (customDbPath != null) {
        final prefsFile =
            File(path.join(customDbPath, 'shared_preferences.json'));
        final prefs = <String, dynamic>{
          _hasPasswordKey: true,
          _passwordHashKey: hashedPassword,
          _saltKey: salt,
        };
        await prefsFile.writeAsString(json.encode(prefs));
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_passwordHashKey, hashedPassword);
        await prefs.setString(_saltKey, salt);
        await prefs.setBool(_hasPasswordKey, true);
      }
      print("AuthService: Password setup successful.");
      return true;
    } catch (e) {
      print("AuthService: Error setting up password - $e");
      return false;
    }
  }

  Future<bool> verifyPassword(String password, {String? customDbPath}) async {
    if (password.isEmpty) {
      print("AuthService: Password cannot be empty for verification.");
      return false;
    }
    try {
      String? storedHash;
      String? salt;

      if (customDbPath != null) {
        final prefsFile =
            File(path.join(customDbPath, 'shared_preferences.json'));
        if (!await prefsFile.exists()) return false;
        final content = await prefsFile.readAsString();
        final prefs = json.decode(content) as Map<String, dynamic>;
        storedHash = prefs[_passwordHashKey] as String?;
        salt = prefs[_saltKey] as String?;
      } else {
        final prefs = await SharedPreferences.getInstance();
        storedHash = prefs.getString(_passwordHashKey);
        salt = prefs.getString(_saltKey);
      }

      if (storedHash == null || salt == null) {
        print("AuthService: No stored password found.");
        return false;
      }

      final hashedPassword = _hashPassword(password, salt);
      return hashedPassword == storedHash;
    } catch (e) {
      print("AuthService: Error verifying password - $e");
      return false;
    }
  }

  Future<void> resetPassword({String? customDbPath}) async {
    try {
      if (customDbPath != null) {
        final prefsFile =
            File(path.join(customDbPath, 'shared_preferences.json'));
        if (await prefsFile.exists()) {
          await prefsFile.delete();
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_hasPasswordKey);
        await prefs.remove(_passwordHashKey);
        await prefs.remove(_saltKey);
      }
      print("AuthService: Password reset successful.");
    } catch (e) {
      print("AuthService: Error resetting password - $e");
      rethrow;
    }
  }

  String _generateSalt({int length = 16}) {
    // A more robust salt generation could use Random.secure()
    // For this example, keeping it simple but slightly improved
    final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    final randomComponent =
        (DateTime.now().millisecond * DateTime.now().second).toString();
    final combined =
        utf8.encode("$timestamp${randomComponent}a_fixed_pepper_string");
    return sha256
        .convert(combined)
        .toString()
        .substring(0, length); // Use a portion as salt
  }

  String _hashPassword(String password, String salt) {
    // It's common to hash multiple times (stretching) but sha256 is strong.
    // Ensure consistent encoding.
    final saltedPasswordBytes = utf8.encode(password + salt);
    return sha256.convert(saltedPasswordBytes).toString();
  }

  // This method is not directly used if SQLCipher handles DB key derivation from password
  // or if EncryptionService uses the password directly.
  // It's more for deriving a separate key if needed.
  String getDatabaseEncryptionKeyFromPassword(String password, String salt) {
    // Example: Use PBKDF2 if you were to derive a key manually for other crypto operations
    // For now, just a strong hash.
    final saltedPasswordBytes = utf8.encode("$password${salt}db_key_pepper");
    return sha256.convert(saltedPasswordBytes).toString();
  }
}
