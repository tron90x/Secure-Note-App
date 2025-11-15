import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'rust_crypto_compat_service.dart';

class RustModeDbService {
  // Constants matching Rust db.rs schema
  static const String tableEntries = 'entries';
  static const String colEntryId = 'id'; // INTEGER PRIMARY KEY
  static const String colEntryNameEncryptedB64 =
      'name_encrypted_b64'; // TEXT NOT NULL
  static const String colEntryLastModified =
      'last_modified'; // INTEGER NOT NULL

  static const String tableNotes = 'notes';
  static const String colNoteId = 'note_id'; // INTEGER PRIMARY KEY
  static const String colNoteEntryId =
      'entry_id'; // INTEGER NOT NULL (FK to entries.id)
  static const String colNoteContentEncryptedB64 =
      'content_encrypted_b64'; // TEXT NOT NULL
  static const String colNoteCreationTimestamp =
      'creation_timestamp'; // INTEGER NOT NULL

  final RustCryptoCompatService _cryptoService;
  Database? _database;
  String? _dbPath;

  RustModeDbService(this._cryptoService);

  Future<void> open(String dbPath) async {
    if (_database != null && _database!.isOpen && _dbPath == dbPath) {
      print('RustModeDbService: Database at $dbPath already open.');
      return;
    }
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      print('RustModeDbService: Closed previous database.');
    }

    _dbPath = dbPath;
    try {
      DatabaseFactory factory;
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        factory = databaseFactoryFfi;
      } else {
        factory = databaseFactory;
      }
      _database = await factory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          readOnly: false, // We need write access
          // The Rust app's DB schema is expected to exist.
          // We won't run onCreate or onUpgrade here, as we're connecting to an existing DB.
          // If schema validation is needed, it would be a separate step.
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
            print('RustModeDbService: Foreign keys PRAGMA executed.');
          },
        ),
      );
      print('RustModeDbService: Database opened successfully at $dbPath');
    } catch (e) {
      print('RustModeDbService: Error opening database at $dbPath: $e');
      _dbPath = null;
      _database = null;
      rethrow;
    }
  }

  Future<Database> get _db async {
    if (_database == null || !_database!.isOpen) {
      throw Exception(
          'RustModeDbService: Database is not open. Call open(dbPath) first.');
    }
    return _database!;
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      print('RustModeDbService: Database closed.');
    }
    _database = null;
    _dbPath = null;
  }

  // --- Entry Operations ---

  Future<int> insertEntry(String entryName, String password) async {
    final db = await _db;
    final plaintextBytes = Uint8List.fromList(utf8.encode(entryName));
    final encryptedBytes = await _cryptoService.encryptRustStandardFormat(
        plaintextBytes, password);
    if (encryptedBytes == null) {
      throw Exception('RustModeDbService: Encryption failed for entry name.');
    }
    final nameEncryptedB64 = base64Encode(encryptedBytes);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return await db.insert(
      RustModeDbService.tableEntries,
      {
        RustModeDbService.colEntryNameEncryptedB64: nameEncryptedB64,
        RustModeDbService.colEntryLastModified: timestamp,
      },
    );
  }

  Future<void> updateEntryName(
      int entryId, String newEntryName, String password) async {
    final db = await _db;
    final plaintextBytes = Uint8List.fromList(utf8.encode(newEntryName));
    final encryptedBytes = await _cryptoService.encryptRustStandardFormat(
        plaintextBytes, password);
    if (encryptedBytes == null) {
      throw Exception(
          'RustModeDbService: Encryption failed for new entry name.');
    }
    final nameEncryptedB64 = base64Encode(encryptedBytes);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await db.update(
      RustModeDbService.tableEntries,
      {
        RustModeDbService.colEntryNameEncryptedB64: nameEncryptedB64,
        RustModeDbService.colEntryLastModified: timestamp,
      },
      where: '${RustModeDbService.colEntryId} = ?',
      whereArgs: [entryId],
    );
  }

  Future<int> deleteEntry(int entryId) async {
    final db = await _db;
    // Notes associated with this entry will be deleted due to 'ON DELETE CASCADE'
    return await db.delete(
      RustModeDbService.tableEntries,
      where: '${RustModeDbService.colEntryId} = ?',
      whereArgs: [entryId],
    );
  }

  // --- Note Operations ---

  Future<int> insertNote(
      int entryId, String noteContent, String password) async {
    final db = await _db;
    final plaintextBytes = Uint8List.fromList(utf8.encode(noteContent));
    final encryptedBytes = await _cryptoService.encryptRustStandardFormat(
        plaintextBytes, password);
    if (encryptedBytes == null) {
      throw Exception('RustModeDbService: Encryption failed for note content.');
    }
    final contentEncryptedB64 = base64Encode(encryptedBytes);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return await db.insert(
      RustModeDbService.tableNotes,
      {
        RustModeDbService.colNoteEntryId: entryId,
        RustModeDbService.colNoteContentEncryptedB64: contentEncryptedB64,
        RustModeDbService.colNoteCreationTimestamp: timestamp,
      },
    );
  }

  Future<void> updateNoteContent(
      int noteId, String newNoteContent, String password) async {
    final db = await _db;
    final plaintextBytes = Uint8List.fromList(utf8.encode(newNoteContent));
    final encryptedBytes = await _cryptoService.encryptRustStandardFormat(
        plaintextBytes, password);
    if (encryptedBytes == null) {
      throw Exception(
          'RustModeDbService: Encryption failed for new note content.');
    }
    final contentEncryptedB64 = base64Encode(encryptedBytes);
    // Note: The Rust app's update_note_content doesn't update any timestamp.
    // We'll match that behavior.

    await db.update(
      RustModeDbService.tableNotes,
      {
        RustModeDbService.colNoteContentEncryptedB64: contentEncryptedB64,
      },
      where: '${RustModeDbService.colNoteId} = ?',
      whereArgs: [noteId],
    );
  }

  Future<int> deleteNote(int noteId) async {
    final db = await _db;
    return await db.delete(
      RustModeDbService.tableNotes,
      where: '${RustModeDbService.colNoteId} = ?',
      whereArgs: [noteId],
    );
  }

  // --- Read Operations (Example - you'll need more based on UI needs) ---
  // These would typically decrypt data after fetching.
  // For brevity, I'm not implementing all read operations from Rust db.rs here,
  // but the pattern would be: fetch raw, then decrypt relevant fields.

  // Example: Get a single entry (you'd decrypt the name)
  Future<Map<String, dynamic>?> getEntry(int entryId, String password) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      RustModeDbService.tableEntries,
      where: '${RustModeDbService.colEntryId} = ?',
      whereArgs: [entryId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      final entry = Map<String, dynamic>.from(maps.first);
      final encryptedNameB64 =
          entry[RustModeDbService.colEntryNameEncryptedB64] as String?;
      if (encryptedNameB64 != null) {
        try {
          final decryptedNameBytes =
              await _cryptoService.decryptRustStandardFormat(
            base64Decode(encryptedNameB64),
            password,
          );
          if (decryptedNameBytes != null) {
            entry['decrypted_name'] = utf8.decode(decryptedNameBytes);
          }
        } catch (e) {
          print(
              'RustModeDbService: Failed to decrypt entry name for ID $entryId: $e');
          entry['decrypted_name'] = 'DECRYPTION_ERROR';
        }
      }
      return entry;
    }
    return null;
  }

  // Example: Get notes for an entry (you'd decrypt content)
  Future<List<Map<String, dynamic>>> getNotesForEntry(
      int entryId, String password) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      RustModeDbService.tableNotes,
      where: '${RustModeDbService.colNoteEntryId} = ?',
      whereArgs: [entryId],
      orderBy: '${RustModeDbService.colNoteCreationTimestamp} DESC',
    );

    List<Map<String, dynamic>> decryptedNotes = [];
    for (var noteMap in maps) {
      final note = Map<String, dynamic>.from(noteMap);
      final encryptedContentB64 =
          note[RustModeDbService.colNoteContentEncryptedB64] as String?;
      if (encryptedContentB64 != null) {
        try {
          final decryptedContentBytes =
              await _cryptoService.decryptRustStandardFormat(
            base64Decode(encryptedContentB64),
            password,
          );
          if (decryptedContentBytes != null) {
            note['decrypted_content'] = utf8.decode(decryptedContentBytes);
          }
        } catch (e) {
          print(
              'RustModeDbService: Failed to decrypt note content for note ID ${note[RustModeDbService.colNoteId]}: $e');
          note['decrypted_content'] = 'DECRYPTION_ERROR';
        }
      }
      decryptedNotes.add(note);
    }
    return decryptedNotes;
  }

  // You would add more methods like getAllEntries, getNotesForEntryMonthYear etc.,
  // following the pattern of fetching data and then decrypting it using _cryptoService.

  Future<List<Map<String, dynamic>>> getAllEntries(String password) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      RustModeDbService.tableEntries,
      orderBy: '${RustModeDbService.colEntryLastModified} DESC',
    );

    List<Map<String, dynamic>> decryptedEntries = [];
    for (var entryMap in maps) {
      final entry = Map<String, dynamic>.from(entryMap);
      final encryptedNameB64 =
          entry[RustModeDbService.colEntryNameEncryptedB64] as String?;
      if (encryptedNameB64 != null) {
        try {
          final decryptedNameBytes =
              await _cryptoService.decryptRustStandardFormat(
            base64Decode(encryptedNameB64),
            password,
          );
          if (decryptedNameBytes != null) {
            entry['decrypted_name'] =
                utf8.decode(decryptedNameBytes, allowMalformed: true);
          } else {
            entry['decrypted_name'] = 'DECRYPTION_FAILED_NULL_BYTES';
          }
        } catch (e) {
          print(
              'RustModeDbService: Failed to decrypt entry name for ID ${entry[RustModeDbService.colEntryId]}: $e');
          entry['decrypted_name'] = 'DECRYPTION_ERROR';
        }
      } else {
        entry['decrypted_name'] = 'MISSING_NAME_DATA';
      }
      decryptedEntries.add(entry);
    }
    return decryptedEntries;
  }

  Future<List<Map<String, dynamic>>> getNotesForEntryMonthYear(
      int entryId, int year, int month, String password) async {
    final db = await _db;

    // Construct date range for the query. SQLite's strftime and date functions are powerful here.
    // Example: WHERE strftime('%Y', datetime(creation_timestamp, 'unixepoch')) = 'YYYY' AND strftime('%m', ...) = 'MM'
    // The Rust app uses this approach.
    final yearStr = year.toString();
    final monthStr = month.toString().padLeft(2, '0');

    final List<Map<String, dynamic>> maps = await db.query(
      RustModeDbService.tableNotes,
      where:
          '${RustModeDbService.colNoteEntryId} = ? AND strftime(\'%Y\', datetime(${RustModeDbService.colNoteCreationTimestamp}, \'unixepoch\')) = ? AND strftime(\'%m\', datetime(${RustModeDbService.colNoteCreationTimestamp}, \'unixepoch\')) = ?',
      whereArgs: [entryId, yearStr, monthStr],
      orderBy: '${RustModeDbService.colNoteCreationTimestamp} DESC',
    );

    List<Map<String, dynamic>> decryptedNotes = [];
    for (var noteMap in maps) {
      final note = Map<String, dynamic>.from(noteMap);
      final encryptedContentB64 =
          note[RustModeDbService.colNoteContentEncryptedB64] as String?;
      if (encryptedContentB64 != null) {
        try {
          final decryptedContentBytes =
              await _cryptoService.decryptRustStandardFormat(
            base64Decode(encryptedContentB64),
            password,
          );
          if (decryptedContentBytes != null) {
            note['decrypted_content'] =
                utf8.decode(decryptedContentBytes, allowMalformed: true);
          } else {
            note['decrypted_content'] = 'DECRYPTION_FAILED_NULL_BYTES';
          }
        } catch (e) {
          print(
              'RustModeDbService: Failed to decrypt note content for note ID ${note[RustModeDbService.colNoteId]}: $e');
          note['decrypted_content'] = 'DECRYPTION_ERROR';
        }
      } else {
        note['decrypted_content'] = 'MISSING_CONTENT_DATA';
      }
      decryptedNotes.add(note);
    }
    return decryptedNotes;
  }
}
