import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  encrypt.Encrypter? _encrypter;
  encrypt.IV? _iv;
  bool _isInitialized = false;

  // This service is primarily for field-level encryption on Windows,
  // as SQLCipher handles full database encryption on mobile.
  void initialize(String password) {
    if (password.isEmpty) {
      print('EncryptionService: Password cannot be empty for initialization.');
      _isInitialized = false;
      return; // Or throw Exception
    }

    try {
      // Generate a key from the password using SHA-256 (32 bytes for AES-256)
      final keyBytes =
          Uint8List.fromList(sha256.convert(utf8.encode(password)).bytes);
      final key = encrypt.Key(keyBytes);

      // Generate a fixed IV from the password (16 bytes for AES)
      // Using a different derivation for IV than the key itself
      final ivSeed = utf8.encode(
          '${password}NaCl'); // "NaCl" for salt, just to make it different
      final ivBytes =
          Uint8List.fromList(sha256.convert(ivSeed).bytes.sublist(0, 16));
      _iv = encrypt.IV(ivBytes);

      _encrypter = encrypt.Encrypter(
          encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
      _isInitialized = true;
      print(
          'EncryptionService initialized successfully (for Windows field encryption).');
    } catch (e) {
      print('Error initializing EncryptionService: $e');
      _isInitialized = false;
      // Consider rethrowing or handling more gracefully
    }
  }

  String encryptData(String data) {
    if (!Platform.isWindows ||
        !_isInitialized ||
        _encrypter == null ||
        _iv == null) {
      // If not on Windows, or not initialized, return original data
      // as SQLCipher will handle encryption on mobile.
      return data;
    }
    if (data.isEmpty) return ''; // Handle empty string encryption if necessary

    try {
      return _encrypter!.encrypt(data, iv: _iv!).base64;
    } catch (e) {
      print('Error encrypting data with EncryptionService: $e');
      return data; // Fallback or rethrow
    }
  }

  String decryptData(String encryptedData) {
    if (!Platform.isWindows ||
        !_isInitialized ||
        _encrypter == null ||
        _iv == null) {
      // If not on Windows, or not initialized, return original data
      return encryptedData;
    }
    if (encryptedData.isEmpty) return '';

    try {
      // Check if the data is in base64 format
      if (!RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(encryptedData)) {
        print(
            'EncryptionService: Data is not in base64 format, returning as is: $encryptedData');
        return encryptedData;
      }

      final encryptedObject = encrypt.Encrypted.fromBase64(encryptedData);
      return _encrypter!.decrypt(encryptedObject, iv: _iv!);
    } catch (e) {
      print(
          'Error decrypting data with EncryptionService: $encryptedData. Error: $e');
      // If decryption fails, return the original data
      return encryptedData;
    }
  }

  bool get isInitialized => _isInitialized;
}
