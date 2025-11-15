import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class IndividualNoteEncryptionService {
  static const String _encryptionMarker = "🔒ENCRYPTED_NOTE_MARKER🔒";
  static const String _ivSeparator = "::IV::";

  // Generate a random encryption marker
  static String generateEncryptionMarker() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }

  // Derive a 256-bit key from the password
  static encrypt.Key deriveKey(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return encrypt.Key.fromBase64(base64Encode(hash.bytes));
  }

  // Encrypt note content
  static String encryptNote(String content, String password) {
    final key = deriveKey(password);
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(content, iv: iv);
    // Store the IV with the encrypted content
    return '${encrypted.base64}$_ivSeparator${iv.base64}';
  }

  // Decrypt note content
  static String decryptNote(String encryptedContent, String password) {
    // Remove all encryption markers before attempting decryption
    String contentToDecrypt = encryptedContent;
    while (contentToDecrypt.contains(_encryptionMarker)) {
      contentToDecrypt = contentToDecrypt.replaceAll(_encryptionMarker, '');
    }

    final key = deriveKey(password);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    try {
      // Try the new format first (with IV)
      if (contentToDecrypt.contains(_ivSeparator)) {
        final parts = contentToDecrypt.split(_ivSeparator);
        if (parts.length != 2) {
          throw Exception('Invalid encrypted content format');
        }

        final encryptedBase64 = parts[0];
        final ivBase64 = parts[1];
        final iv = encrypt.IV.fromBase64(ivBase64);
        final encrypted = encrypt.Encrypted.fromBase64(encryptedBase64);
        return encrypter.decrypt(encrypted, iv: iv);
      } else {
        // Try the old format (without IV)
        final iv = encrypt.IV.fromLength(16);
        final encrypted = encrypt.Encrypted.fromBase64(contentToDecrypt);
        return encrypter.decrypt(encrypted, iv: iv);
      }
    } catch (e) {
      throw Exception(
          'Failed to decrypt note: Invalid password or corrupted data');
    }
  }

  // Check if content is encrypted
  static bool isEncrypted(String content) {
    return content.startsWith(_encryptionMarker);
  }
}
