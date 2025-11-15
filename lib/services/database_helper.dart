import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'encryption_service.dart'; // Your EncryptionService

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String _dbName =
      'notes_app_v2.db'; // Changed name slightly to avoid old schema issues during dev
  final EncryptionService _encryptionService = EncryptionService();
  static const int _databaseVersion =
      5; // Increment version for new column and image attachments

  // Categories Table
  static const String tableCategories = 'categories';
  static const String colCategoryId = 'id';
  static const String colCategoryName = 'name';
  static const String colCategoryCreatedAt = 'createdAt';

  // Notes Table
  static const String tableNotes = 'notes';
  static const String colNoteId = 'id';
  static const String colNoteCategoryId = 'categoryId';
  static const String colNoteTitle = 'title';
  static const String colNoteContent = 'content';
  static const String colNoteCreatedAt = 'createdAt';
  static const String colNoteUpdatedAt = 'updatedAt';
  static const String colNoteBackgroundColor = 'noteBackgroundColor';
  static const String colNoteTitleColor = 'noteTitleColor';

  // Entries Table
  static const String tableEntries = 'entries';
  static const String colEntryId = 'id';
  static const String colEntryName = 'name_encrypted_b64';
  static const String colEntryLastModified = 'last_modified';

  // Image Attachments Table
  static const String tableImageAttachments = 'image_attachments';
  static const String colImageId = 'id';
  static const String colImageNoteId = 'note_id';
  static const String colImageData = 'image_data';
  static const String colImageName = 'image_name';
  static const String colImageCreatedAt = 'created_at';

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    throw Exception(
      'Database not initialized or closed. Call initializeDatabase(password) first.',
    );
  }

  Future<String?> getDatabasePath({String? customDbPath}) async {
    if (Platform.isWindows) {
      if (customDbPath != null) {
        return path.join(customDbPath, _dbName);
      } else {
        final dir = await getApplicationSupportDirectory();
        return path.join(dir.path, _dbName);
      }
    } else {
      if (customDbPath != null) {
        return path.join(customDbPath, _dbName);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        return path.join(dir.path, _dbName);
      }
    }
  }

  Future<void> initializeDatabase(String password,
      {String? customDbPath}) async {
    try {
      print('Attempting to initialize database...');
      if (_database != null && _database!.isOpen) {
        print(
            'Database already initialized and open. Verifying encryption service...');
        _encryptionService.initialize(password);
        return;
      }

      _encryptionService.initialize(password);
      print('Encryption service initialized.');

      _database = await _initDB(password, customDbPath: customDbPath);
      print('Database connection established.');

      await _database!.execute(
          'CREATE TABLE IF NOT EXISTS _internal_test_write (id INTEGER PRIMARY KEY)');
      await _database!.delete('_internal_test_write');
      print('Database write test successful.');
    } catch (e) {
      print('Error during initializeDatabase: $e');
      _database = null;
      rethrow;
    }
  }

  Future<Database> _initDB(String password, {String? customDbPath}) async {
    String dbPath;
    DatabaseFactory factory;

    if (Platform.isWindows) {
      if (customDbPath != null) {
        dbPath = path.join(customDbPath, _dbName);
      } else {
        final dir = await getApplicationSupportDirectory();
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        dbPath = path.join(dir.path, _dbName);
      }
      factory = databaseFactoryFfi;
      print('Using FFI for Windows. DB Path: $dbPath');

      return await factory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: _databaseVersion,
          onCreate: (db, version) async {
            print('Creating database tables...');
            await db.execute('''
              CREATE TABLE entries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name_encrypted_b64 TEXT NOT NULL,
                last_modified INTEGER NOT NULL
              )
            ''');
            print('Created entries table');

            await db.execute('''
              CREATE TABLE notes (
                note_id INTEGER PRIMARY KEY AUTOINCREMENT,
                entry_id INTEGER NOT NULL,
                title TEXT,
                content_encrypted_b64 TEXT NOT NULL,
                creation_timestamp INTEGER NOT NULL,
                noteBackgroundColor TEXT,
                noteTitleColor TEXT,
                is_individually_encrypted INTEGER DEFAULT 0,
                encryption_marker TEXT,
                FOREIGN KEY (entry_id) REFERENCES entries (id) ON DELETE CASCADE
              )
            ''');
            print('Created notes table');

            await db.execute('''
              CREATE TABLE image_attachments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                note_id INTEGER NOT NULL,
                image_data BLOB NOT NULL,
                image_name TEXT NOT NULL,
                created_at INTEGER NOT NULL,
                FOREIGN KEY (note_id) REFERENCES notes (note_id) ON DELETE CASCADE
              )
            ''');
            print('Created image attachments table');
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            print('Upgrading database from version $oldVersion to $newVersion');
            if (oldVersion < 2) {
              // Add new color columns to notes table
              await db.execute(
                  'ALTER TABLE notes ADD COLUMN noteBackgroundColor TEXT');
              await db
                  .execute('ALTER TABLE notes ADD COLUMN noteTitleColor TEXT');
              print('Added color columns to notes table');
            }
            if (oldVersion < 3) {
              // Add encryption-related columns
              await db.execute(
                  'ALTER TABLE notes ADD COLUMN is_individually_encrypted INTEGER DEFAULT 0');
              await db.execute(
                  'ALTER TABLE notes ADD COLUMN encryption_marker TEXT');
              print('Added encryption columns to notes table');
            }
            if (oldVersion < 4) {
              await db.execute('''
                CREATE TABLE image_attachments (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  note_id INTEGER NOT NULL,
                  image_data BLOB NOT NULL,
                  image_name TEXT NOT NULL,
                  created_at INTEGER NOT NULL,
                  FOREIGN KEY (note_id) REFERENCES notes (note_id) ON DELETE CASCADE
                )
              ''');
            }
            if (oldVersion < 5) {
              await db.execute('ALTER TABLE notes ADD COLUMN title TEXT');
              print('Added title column to notes table');
            }
          },
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
            print('Enabled foreign key support');
          },
          readOnly: false,
        ),
      );
    } else {
      if (customDbPath != null) {
        dbPath = path.join(customDbPath, _dbName);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        dbPath = path.join(dir.path, _dbName);
      }
      factory = databaseFactory;
      print('Using SQLCipher for Mobile. DB Path: $dbPath');
      return await factory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: _databaseVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
          },
          readOnly: false,
        ),
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    print("Creating database tables (version $version)...");
    await db.execute('''
      CREATE TABLE entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_encrypted_b64 TEXT NOT NULL,
        last_modified INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE notes (
        note_id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_id INTEGER NOT NULL,
        title TEXT,
        content_encrypted_b64 TEXT NOT NULL,
        creation_timestamp INTEGER NOT NULL,
        noteBackgroundColor TEXT,
        noteTitleColor TEXT,
        is_individually_encrypted INTEGER DEFAULT 0,
        encryption_marker TEXT,
        FOREIGN KEY (entry_id) REFERENCES entries (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE image_attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        note_id INTEGER NOT NULL,
        image_data BLOB NOT NULL,
        image_name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (note_id) REFERENCES notes (note_id) ON DELETE CASCADE
      )
    ''');
    print("Database tables created!");
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from version $oldVersion to $newVersion");
    if (oldVersion < 2) {
      // Add new color columns to notes table
      await db.execute('ALTER TABLE notes ADD COLUMN noteBackgroundColor TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN noteTitleColor TEXT');
      print('Added color columns to notes table');
    }
    if (oldVersion < 3) {
      // Add encryption-related columns
      await db.execute(
          'ALTER TABLE notes ADD COLUMN is_individually_encrypted INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE notes ADD COLUMN encryption_marker TEXT');
      print('Added encryption columns to notes table');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE image_attachments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          note_id INTEGER NOT NULL,
          image_data BLOB NOT NULL,
          image_name TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (note_id) REFERENCES notes (note_id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE notes ADD COLUMN title TEXT');
      print('Added title column to notes table');
    }
  }

  Future<int> insertEntry(String entryName, String password) async {
    final db = await database;
    final encryptedName = _encryptionService.encryptData(entryName);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return await db.insert(
      'entries',
      {
        'name_encrypted_b64': encryptedName,
        'last_modified': timestamp,
      },
    );
  }

  Future<int> insertNote(int entryId, String noteContent, String password,
      {String? title,
      String? backgroundColor,
      String? titleColor,
      bool isIndividuallyEncrypted = false,
      String? encryptionMarker}) async {
    print('DatabaseHelper: Starting insertNote');
    print('DatabaseHelper: Entry ID: $entryId');
    print('DatabaseHelper: Note content length: ${noteContent.length}');

    final db = await database;
    final encryptedContent = _encryptionService.encryptData(noteContent);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    print(
        'DatabaseHelper: Encrypted content length: ${encryptedContent.length}');
    print('DatabaseHelper: Timestamp: $timestamp');

    try {
      final result = await db.insert(
        'notes',
        {
          'entry_id': entryId,
          'title': title,
          'content_encrypted_b64': encryptedContent,
          'creation_timestamp': timestamp,
          'noteBackgroundColor': backgroundColor,
          'noteTitleColor': titleColor,
          'is_individually_encrypted': isIndividuallyEncrypted ? 1 : 0,
          'encryption_marker': encryptionMarker,
        },
      );
      print('DatabaseHelper: Note inserted successfully with ID: $result');
      return result;
    } catch (e) {
      print('DatabaseHelper: Error inserting note: $e');
      print("Error type: ${e.runtimeType}");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> entries = await db.query(
      'entries',
      orderBy: 'last_modified DESC',
    );

    return entries.map((entry) {
      final decryptedName =
          _encryptionService.decryptData(entry['name_encrypted_b64']);
      return {
        'id': entry['id'],
        'decrypted_name': decryptedName,
        'last_modified': entry['last_modified'],
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getNotesForEntryMonthYear(
    int entryId,
    int year,
    int month,
  ) async {
    print('DatabaseHelper: Starting getNotesForEntryMonthYear');
    print('DatabaseHelper: Entry ID: $entryId, Year: $year, Month: $month');

    final db = await database;
    final yearStr = year.toString();
    final monthStr = month.toString().padLeft(2, '0');

    try {
      final List<Map<String, dynamic>> notes = await db.query(
        'notes',
        where:
            'entry_id = ? AND strftime(\'%Y\', datetime(creation_timestamp, \'unixepoch\')) = ? AND strftime(\'%m\', datetime(creation_timestamp, \'unixepoch\')) = ?',
        whereArgs: [entryId, yearStr, monthStr],
        orderBy: 'creation_timestamp DESC',
      );

      print('DatabaseHelper: Found ${notes.length} notes');
      print('DatabaseHelper: Raw notes data: $notes');

      return notes.map((note) {
        try {
          final decryptedContent =
              _encryptionService.decryptData(note['content_encrypted_b64']);
          print(
              'DatabaseHelper: Successfully decrypted note ${note['note_id']}');

          return {
            'note_id': note['note_id'],
            'entry_id': note['entry_id'],
            'title': note['title'],
            'content': decryptedContent,
            'created_at': note['creation_timestamp'],
            'noteBackgroundColor': note['noteBackgroundColor'],
            'noteTitleColor': note['noteTitleColor'],
          };
        } catch (e) {
          print('DatabaseHelper: Error decrypting note ${note['note_id']}: $e');
          return {
            'note_id': note['note_id'],
            'entry_id': note['entry_id'],
            'content': '[Error decrypting note]',
            'created_at': note['creation_timestamp'],
            'noteBackgroundColor': note['noteBackgroundColor'],
            'noteTitleColor': note['noteTitleColor'],
          };
        }
      }).toList();
    } catch (e) {
      print('DatabaseHelper: Error getting notes: $e');
      rethrow;
    }
  }

  Future<void> updateEntryName(
      int entryId, String newEntryName, String password) async {
    final db = await database;
    final encryptedName = _encryptionService.encryptData(newEntryName);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await db.update(
      'entries',
      {
        'name_encrypted_b64': encryptedName,
        'last_modified': timestamp,
      },
      where: 'id = ?',
      whereArgs: [entryId],
    );
  }

  Future<void> updateNoteContent(
      int noteId, String newNoteContent, String password,
      {String? title,
      String? backgroundColor,
      String? titleColor,
      bool isIndividuallyEncrypted = false,
      String? encryptionMarker}) async {
    final db = await database;
    final encryptedContent = _encryptionService.encryptData(newNoteContent);

    final Map<String, dynamic> updateData = {
      'content_encrypted_b64': encryptedContent,
      'is_individually_encrypted': isIndividuallyEncrypted ? 1 : 0,
      'encryption_marker': encryptionMarker,
    };

    if (title != null) {
      updateData['title'] = title;
    }
    if (backgroundColor != null) {
      updateData['noteBackgroundColor'] = backgroundColor;
    }
    if (titleColor != null) {
      updateData['noteTitleColor'] = titleColor;
    }

    await db.update(
      'notes',
      updateData,
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
  }

  Future<int> deleteEntry(int entryId) async {
    print('DatabaseHelper: Starting deleteEntry for ID: $entryId');
    final db = await database;
    try {
      await db.transaction((txn) async {
        // First delete all notes associated with this entry
        print('DatabaseHelper: Deleting associated notes');
        final notesDeleted = await txn.delete(
          tableNotes,
          where: 'entry_id = ?',
          whereArgs: [entryId],
        );

        // Then delete the entry itself
        print('DatabaseHelper: Deleting entry');
        final entryDeleted = await txn.delete(
          tableEntries,
          where: 'id = ?',
          whereArgs: [entryId],
        );

        return notesDeleted +
            entryDeleted; // Return total number of rows deleted
      });
      print('DatabaseHelper: Successfully deleted entry and associated notes');
      return 1; // Return 1 to indicate success
    } catch (e) {
      print('DatabaseHelper: Error deleting entry: $e');
      rethrow;
    }
  }

  Future<int> deleteNote(int noteId) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      print("Database closed.");
    }
    _database = null;
  }

  // Legacy support for 'categories' naming
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    // Map entries to categories for compatibility
    final entries = await getAllEntries();
    return entries
        .map((entry) => {
              colCategoryId: entry['id'],
              colCategoryName: entry['decrypted_name'],
              colCategoryCreatedAt: entry['last_modified'],
            })
        .toList();
  }

  Future<int> insertCategory(Map<String, dynamic> category) async {
    // Map category fields to entry fields
    final name = category[colCategoryName] ?? '';
    const password = ''; // Not used in legacy, but required by insertEntry
    return await insertEntry(name, password);
  }

  Future<List<Map<String, dynamic>>> searchNotes(
    String query, {
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> results = [];

    // Get all notes
    final List<Map<String, dynamic>> allNotes = await db.query(
      'notes',
      orderBy: 'creation_timestamp DESC',
    );

    // Search through decrypted content
    for (final note in allNotes) {
      try {
        // Check category filter first
        if (categoryId != null && note['entry_id'].toString() != categoryId) {
          continue;
        }

        // Check date range filter
        final noteTimestamp = note['creation_timestamp'] as int;
        final noteDate =
            DateTime.fromMillisecondsSinceEpoch(noteTimestamp * 1000);
        if (startDate != null && noteDate.isBefore(startDate)) {
          continue;
        }
        if (endDate != null && noteDate.isAfter(endDate)) {
          continue;
        }

        final decryptedContent = _encryptionService
            .decryptData(note['content_encrypted_b64'] as String);
        if (decryptedContent.toLowerCase().contains(query.toLowerCase())) {
          // Get the entry name for this note
          final entry = await db.query(
            'entries',
            where: 'id = ?',
            whereArgs: [note['entry_id']],
          );

          if (entry.isNotEmpty) {
            final decryptedEntryName = _encryptionService
                .decryptData(entry[0]['name_encrypted_b64'] as String);
            results.add({
              'note_id': note['note_id'],
              'entry_id': note['entry_id'],
              'entry_name': decryptedEntryName,
              'content': decryptedContent,
              'created_at': note['creation_timestamp'],
            });
          }
        }
      } catch (e) {
        print('Error decrypting note during search: $e');
        // Skip this note if decryption fails
        continue;
      }
    }

    return results;
  }

  Future<Map<String, dynamic>> getNoteById(int noteId) async {
    final db = await database;
    final List<Map<String, dynamic>> notes = await db.query(
      'notes',
      where: 'note_id = ?',
      whereArgs: [noteId],
    );

    if (notes.isEmpty) {
      throw Exception('Note not found');
    }

    final note = notes.first;
    final decryptedContent =
        _encryptionService.decryptData(note['content_encrypted_b64']);

    return {
      'note_id': note['note_id'],
      'entry_id': note['entry_id'],
      'title': note['title'],
      'content': decryptedContent,
      'created_at': note['creation_timestamp'],
      'noteBackgroundColor': note['noteBackgroundColor'],
      'noteTitleColor': note['noteTitleColor'],
      'is_individually_encrypted': note['is_individually_encrypted'] == 1,
      'encryption_marker': note['encryption_marker'],
    };
  }

  // Image attachment methods
  Future<int> addImageAttachment(
      int noteId, List<int> imageData, String imageName) async {
    final db = await database;
    return await db.insert(tableImageAttachments, {
      colImageNoteId: noteId,
      colImageData: imageData,
      colImageName: imageName,
      colImageCreatedAt: DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getNoteImageAttachments(int noteId) async {
    final db = await database;
    return await db.query(
      tableImageAttachments,
      columns: [
        colImageId,
        colImageNoteId,
        colImageData,
        colImageName,
        colImageCreatedAt
      ],
      where: '$colImageNoteId = ?',
      whereArgs: [noteId],
    );
  }

  Future<void> deleteImageAttachment(int imageId) async {
    final db = await database;
    await db.delete(
      tableImageAttachments,
      where: '$colImageId = ?',
      whereArgs: [imageId],
    );
  }

  Future<void> deleteNoteImageAttachments(int noteId) async {
    final db = await database;
    await db.delete(
      tableImageAttachments,
      where: '$colImageNoteId = ?',
      whereArgs: [noteId],
    );
  }
}
