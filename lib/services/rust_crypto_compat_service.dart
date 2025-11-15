import 'dart:convert';
import 'dart:typed_data';
import 'dart:math'; // For Random.secure for salt and nonce generation

import 'package:pointycastle/export.dart' as pc;
// No need for 'package:crypto/crypto.dart' as pc.SHA256Digest is used.

// Constants from Rust crypto.rs
const int RUST_KEY_SIZE = 32; // bytes for AES-256
const int RUST_NONCE_SIZE = 12; // bytes (96 bits) for AES-GCM
const int RUST_SALT_SIZE = 16; // bytes
const int RUST_PBKDF_ITERATIONS = 100000;
const int RUST_AUTH_TAG_LENGTH_BITS =
    128; // AES-GCM default tag length (16 bytes)

class RustCryptoCompatService {
  // Derives a key using PBKDF2-HMAC-SHA256, matching Rust's implementation
  Uint8List deriveKey(String password, Uint8List salt) {
    print('RustCompat.deriveKey: Input Salt (${salt.length} bytes): ${salt.sublist(0, min(salt.length, 8)).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}...');
    // Ensure PointyCastle's PBKDF2 is configured to match Rust's pbkdf2_hmac<Sha256>
    // The PBDKF2KeyDerivator in PointyCastle takes an HMac.
    // The block size for SHA256 HMac is 64.
    final derivator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64))
      ..init(pc.Pbkdf2Parameters(salt, RUST_PBKDF_ITERATIONS, RUST_KEY_SIZE));
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }

  // For decrypting standard Rust encrypted data (salt + nonce + ciphertextWithAuthTag)
  Future<Uint8List?> decryptRustStandardFormat(
      Uint8List encryptedDataWithHeader, String password) async {
    if (encryptedDataWithHeader.length <
        RUST_SALT_SIZE + RUST_NONCE_SIZE + (RUST_AUTH_TAG_LENGTH_BITS ~/ 8)) {
      // Ciphertext itself must be at least tag length. Header + tag is minimum.
      print(
          'RustCompat: Encrypted data too short for standard format (salt+nonce+tag). Length: ${encryptedDataWithHeader.length}');
      return null;
    }

    try {
      print('RustCompat: Attempting standard decryption. Total input length: ${encryptedDataWithHeader.length}');
      final salt = encryptedDataWithHeader.sublist(0, RUST_SALT_SIZE);
      print('RustCompat: Salt (${salt.length} bytes): ${salt.sublist(0, min(salt.length, 8)).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}...');
      final nonce = encryptedDataWithHeader.sublist(
          RUST_SALT_SIZE, RUST_SALT_SIZE + RUST_NONCE_SIZE);
      print('RustCompat: Nonce (${nonce.length} bytes): ${nonce.sublist(0, min(nonce.length, 8)).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}...');
      // The rest is ciphertext + authentication tag
      final ciphertextWithAuthTag =
          encryptedDataWithHeader.sublist(RUST_SALT_SIZE + RUST_NONCE_SIZE);
      print('RustCompat: Ciphertext+Tag (${ciphertextWithAuthTag.length} bytes): ${ciphertextWithAuthTag.sublist(0, min(ciphertextWithAuthTag.length, 8)).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}...');

      final keyBytes = deriveKey(password, salt);
      print('RustCompat.decryptStandard: Using key (${keyBytes.length} bytes): ${keyBytes.sublist(0, min(keyBytes.length, 8)).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}...');

      final cipher = pc.GCMBlockCipher(pc.AESEngine())
        ..init(
            false, // false for decryption
            pc.AEADParameters(pc.KeyParameter(keyBytes), RUST_AUTH_TAG_LENGTH_BITS, nonce, Uint8List(0)));

      // Output buffer for plaintext should be ciphertextWithAuthTag.length - (RUST_AUTH_TAG_LENGTH_BITS ~/ 8)
      // However, process() in PointyCastle for GCM decryption expects the ciphertext *including* the tag.
      // It handles stripping the tag and verifying it.
      final outputBufferSize = cipher.getOutputSize(ciphertextWithAuthTag.length);
      final decryptedBytes = Uint8List(outputBufferSize);
      print('RustCompat.Decrypt: Allocated output buffer size for plaintext: $outputBufferSize');

      int processedLen = cipher.processBytes(ciphertextWithAuthTag, 0, 
          ciphertextWithAuthTag.length, decryptedBytes, 0);
      // The doFinal method verifies the authentication tag AND writes any remaining plaintext bytes.
      // It returns the number of bytes written in this final step.
      int finalLen = cipher.doFinal(decryptedBytes, processedLen);

      int actualPlaintextLength = processedLen + finalLen;
      print('RustCompat.Decrypt: Bytes from processBytes: $processedLen, Bytes from doFinal: $finalLen, Total actual plaintext length: $actualPlaintextLength');

      if (actualPlaintextLength > outputBufferSize) {
        print('RustCompat.Decrypt: CRITICAL ERROR - More plaintext bytes ($actualPlaintextLength) written than output buffer size ($outputBufferSize)!');
        return null; // Should not happen if getOutputSize is consistent
      }
      
      // Return only the actual decrypted plaintext, excluding any potential padding in the buffer.
      return decryptedBytes.sublist(0, actualPlaintextLength);
    } catch (e) {
      print('RustCompat: Decryption (standard format) failed: $e');
      // This catch block is crucial. If PointyCastle's doFinal throws an InvalidCipherTextException,
      // it means the authentication tag didn't match, which strongly implies wrong key (password) or corrupted data.
      return null;
    }
  }

  // For decrypting Rust validation.dat data (nonce + ciphertextWithAuthTag, with external masterSalt)
  Future<Uint8List?> decryptRustValidationFormat(
      Uint8List encryptedDataWithNonceAndTag,
      String password,
      Uint8List masterSalt) async {
    if (encryptedDataWithNonceAndTag.length <
        RUST_NONCE_SIZE + (RUST_AUTH_TAG_LENGTH_BITS ~/ 8)) {
      print(
          'RustCompat: Encrypted data too short for validation format (nonce+tag). Length: ${encryptedDataWithNonceAndTag.length}');
      return null;
    }

    try {
      final nonce = encryptedDataWithNonceAndTag.sublist(0, RUST_NONCE_SIZE);
      // The rest is ciphertext + authentication tag
      final ciphertextWithAuthTag =
          encryptedDataWithNonceAndTag.sublist(RUST_NONCE_SIZE);

      final keyBytes = deriveKey(password, masterSalt);

      final cipher = pc.GCMBlockCipher(pc.AESEngine())
        ..init(
            false, // Decryption
            pc.AEADParameters(pc.KeyParameter(keyBytes),
                RUST_AUTH_TAG_LENGTH_BITS, nonce, Uint8List(0)));

      final outputBufferSize = cipher.getOutputSize(ciphertextWithAuthTag.length);
      final decryptedBytes = Uint8List(outputBufferSize);
      print('RustCompat.DecryptValidation: Allocated output buffer size for plaintext: $outputBufferSize');

      int processedLen = cipher.processBytes(ciphertextWithAuthTag, 0, 
          ciphertextWithAuthTag.length, decryptedBytes, 0);
      int finalLen = cipher.doFinal(decryptedBytes, processedLen);

      int actualPlaintextLength = processedLen + finalLen;
      print('RustCompat.DecryptValidation: Bytes from processBytes: $processedLen, Bytes from doFinal: $finalLen, Total actual plaintext length: $actualPlaintextLength');

      if (actualPlaintextLength > outputBufferSize) {
        print('RustCompat.DecryptValidation: CRITICAL ERROR - More plaintext bytes ($actualPlaintextLength) written than output buffer size ($outputBufferSize)!');
        return null;
      }
      
      return decryptedBytes.sublist(0, actualPlaintextLength);
    } catch (e) {
      print('RustCompat: Decryption (validation format) failed: $e');
      return null;
    }
  }

  // For encrypting data to the standard Rust format (salt + nonce + ciphertextWithAuthTag)
  Future<Uint8List?> encryptRustStandardFormat(
      Uint8List plaintext, String password) async {
    try {
      // 1. Generate Salt (16 bytes)
      final secureRandom = Random.secure();
      final salt = Uint8List(RUST_SALT_SIZE);
      for (int i = 0; i < RUST_SALT_SIZE; i++) {
        salt[i] = secureRandom.nextInt(256);
      }

      // 2. Derive Key
      final keyBytes = deriveKey(password, salt);

      // 3. Generate Nonce (12 bytes)
      final nonce = Uint8List(RUST_NONCE_SIZE);
      for (int i = 0; i < RUST_NONCE_SIZE; i++) {
        nonce[i] = secureRandom.nextInt(256);
      }

      // 4. Encrypt using AES-GCM
      final cipher = pc.GCMBlockCipher(pc.AESEngine())
        ..init(
            true, // true for encryption
            pc.AEADParameters(pc.KeyParameter(keyBytes), RUST_AUTH_TAG_LENGTH_BITS, nonce, Uint8List(0)));

      final allocatedSize = cipher.getOutputSize(plaintext.length);
      final ciphertextWithAuthTag = Uint8List(allocatedSize);
      print('RustCompat.Encrypt: Plaintext length: ${plaintext.length}');
      print('RustCompat.Encrypt: Allocated buffer size for ciphertext+tag: $allocatedSize');

      int ciphertextLen = cipher.processBytes(plaintext, 0, plaintext.length, ciphertextWithAuthTag, 0);
      print('RustCompat.Encrypt: Bytes written by processBytes (ciphertext part): $ciphertextLen');

      int tagLen = cipher.doFinal(ciphertextWithAuthTag, ciphertextLen); // Appends authentication tag
      print('RustCompat.Encrypt: Bytes written by doFinal (tag part): $tagLen');

      int totalActualCryptoBytes = ciphertextLen + tagLen;
      print('RustCompat.Encrypt: Total actual crypto bytes (ciphertext + tag): $totalActualCryptoBytes');

      if (totalActualCryptoBytes > allocatedSize) {
        print('RustCompat.Encrypt: CRITICAL ERROR - More bytes written than allocated!');
        // This case should ideally not happen if getOutputSize is correct for allocation.
      }
      // If totalActualCryptoBytes < allocatedSize, the buffer was overallocated.
      // We should only use the part of the buffer that contains actual data.

      // 5. Combine: salt + nonce + ciphertextWithAuthTag
      final result = BytesBuilder(); // Requires dart:typed_data, already imported
      result.add(salt);
      result.add(nonce);
      // If overallocation happened, only add the valid part of ciphertextWithAuthTag
      if (totalActualCryptoBytes < allocatedSize) {
        print('RustCompat.Encrypt: Using sublist of ciphertextWithAuthTag due to overallocation. Length: $totalActualCryptoBytes');
        result.add(ciphertextWithAuthTag.sublist(0, totalActualCryptoBytes));
      } else {
        result.add(ciphertextWithAuthTag); // Assumes totalActualCryptoBytes == allocatedSize
      }

      return result.toBytes();
    } catch (e) {
      print('RustCompat: Encryption (standard format) failed: $e');
      return null;
    }
  }

  Future<void> selfTestEncryptionDecryption() async {
    print('RustCompat: --- Starting Self Test ---');
    const String testPassword = "testpassword123";
    const String testPlaintext = "This is a secret message for self-test.";
    final plaintextBytes = Uint8List.fromList(utf8.encode(testPlaintext));

    print('RustCompat.SelfTest: Encrypting: "$testPlaintext" with password: "$testPassword"');
    final encryptedData = await encryptRustStandardFormat(plaintextBytes, testPassword);

    if (encryptedData == null) {
      print('RustCompat.SelfTest: ENCRYPTION FAILED.');
      print('RustCompat: --- Self Test Finished ---');
      return;
    }
    print('RustCompat.SelfTest: Encryption successful. Encrypted data length: ${encryptedData.length}');
    print('RustCompat.SelfTest: Encrypted data (hex, first 16 bytes): ${encryptedData.sublist(0, min(encryptedData.length, 16)).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');

    print('RustCompat.SelfTest: Decrypting...');
    final decryptedBytes = await decryptRustStandardFormat(encryptedData, testPassword);

    if (decryptedBytes == null) {
      print('RustCompat.SelfTest: DECRYPTION FAILED (returned null).');
    } else {
      // Primary check: Compare byte arrays directly
      bool bytesMatch = false;
      if (plaintextBytes.length == decryptedBytes.length) {
        bytesMatch = true;
        for (int i = 0; i < plaintextBytes.length; i++) {
          if (plaintextBytes[i] != decryptedBytes[i]) {
            bytesMatch = false;
            break;
          }
        }
      }

      if (bytesMatch) {
        print('RustCompat.SelfTest: SUCCESS - Decrypted byte array MATCHES original plaintext byte array.');
        // Secondary check: String conversion (should also match if bytes match)
        try {
          final decryptedText = utf8.decode(decryptedBytes);
          print('RustCompat.SelfTest: Decoded string: "$decryptedText"');
          if (decryptedText == testPlaintext) {
            print('RustCompat.SelfTest: SUCCESS - Decrypted string also matches original string.');
          } else {
            // This case should be rare if bytes match but strings don't, implies UTF8 issue or original testPlaintext issue
            print('RustCompat.SelfTest: WARNING - Bytes matched, but decoded string DOES NOT MATCH original string. This is unusual.');
            print('RustCompat.SelfTest: Original String: "$testPlaintext"');
            print('RustCompat.SelfTest: Decoded String: "$decryptedText"');
          }
        } catch (e) {
          print('RustCompat.SelfTest: ERROR - Byte arrays matched, but UTF-8 decoding of decrypted bytes failed: $e');
        }
      } else {
        print('RustCompat.SelfTest: ERROR - Decrypted byte array DOES NOT MATCH original plaintext byte array.');
        print('RustCompat.SelfTest: Original Bytes Length: ${plaintextBytes.length}');
        print('RustCompat.SelfTest: Original Bytes (hex): ${plaintextBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
        print('RustCompat.SelfTest: Decrypted Bytes Length: ${decryptedBytes.length}');
        print('RustCompat.SelfTest: Decrypted Bytes (hex): ${decryptedBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
        
        // Attempt to decode and print strings anyway for more info, but expect differences
        try {
          final originalDecodedForDebug = utf8.decode(plaintextBytes);
          final decryptedTextForDebug = utf8.decode(decryptedBytes, allowMalformed: true); // allow malformed for debugging
          print('RustCompat.SelfTest: Original (debug decode): "$originalDecodedForDebug"');
          print('RustCompat.SelfTest: Decrypted (debug decode): "$decryptedTextForDebug"');
        } catch (e) {
          print('RustCompat.SelfTest: Further error during debug string decoding: $e');
        }
      }
    }
    print('RustCompat: --- Self Test Finished ---');
  }
}

// Helper to parse the validation.dat JSON structure
class RustValidationData {
  final String testCiphertextB64;
  final String masterSaltB64;

  RustValidationData(
      {required this.testCiphertextB64, required this.masterSaltB64});

  factory RustValidationData.fromJson(Map<String, dynamic> json) {
    // Ensure keys match exactly with your Rust JSON output for validation.dat
    return RustValidationData(
      testCiphertextB64: json['test_ciphertext_b64'] as String,
      masterSaltB64: json['master_salt_b64'] as String,
    );
  }
}
