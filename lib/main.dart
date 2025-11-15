import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:sqflite/sqflite.dart';
import 'dart:io'; // For Platform checks and File
import 'package:file_selector/file_selector.dart'; // For file picking
import 'dart:convert'; // For utf8 and base64
import 'dart:typed_data'; // For Uint8List
import 'package:provider/provider.dart';

import 'services/database_helper.dart';
import 'services/auth_service.dart';
import 'screens/category_notes_screen.dart';
import 'services/rust_crypto_compat_service.dart'; // Import the new service
import 'services/rust_mode_db_service.dart'; // Import the Rust mode DB service
// Import your Rust DB display screen (we'll create a placeholder for now)
import 'screens/rust_db_viewer_screen.dart';
import 'screens/native_storage_options_dialog.dart';
import 'services/theme_service.dart';
import 'services/localization_service.dart';
import 'screens/fake_error_screen.dart';
import 'l10n/app_localizations.dart';
import 'l10n/kab_fallback_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize FFI for SQLite (desktop only)
    ffi.sqfliteFfiInit();
    databaseFactory = ffi.databaseFactoryFfi;
  }
  // On Android/iOS, do NOT set databaseFactory, use default

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final localizationService = Provider.of<LocalizationService>(context);

    return MaterialApp(
      title: 'Secure Note App',
      localizationsDelegates: const [
        // Fallbacks so Material/Cupertino work with 'kab'
        KabMaterialLocalizationsDelegate(),
        KabCupertinoLocalizationsDelegate(),
        // App strings + default delegates
        ...AppLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localizationService.currentLocale,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 2.0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 2.0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      themeMode:
          themeService.shouldUseDarkMode() ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const FakeErrorScreen(),
      routes: {
        '/openRustDb': (context) => const OpenRustDbScreen(),
      },
    );
  }
}

// Screen for handling Rust DB file selection and password
class OpenRustDbScreen extends StatefulWidget {
  const OpenRustDbScreen({super.key});

  @override
  State<OpenRustDbScreen> createState() => _OpenRustDbScreenState();
}

class _OpenRustDbScreenState extends State<OpenRustDbScreen> {
  final _passwordController = TextEditingController();
  final RustCryptoCompatService _rustCryptoService = RustCryptoCompatService();
  // No direct DatabaseHelper here as we're opening a plain SQLite file.
  // We'll pass the path and password to the viewer screen.

  String? _dbFilePath;
  String? _validationFilePath;
  bool _isLoading = false;
  String? _statusMessage;
  bool _successfullyNavigated = false; // Flag to track successful navigation

  late final RustModeDbService _rustDbService;

  @override
  void initState() {
    super.initState();
    // Run a self-test of the crypto service
    RustCryptoCompatService().selfTestEncryptionDecryption();
    _rustDbService = RustModeDbService(_rustCryptoService);
  }

  Future<void> _pickDbFile() async {
    const typeGroup = XTypeGroup(
      label: 'SQLite Database',
      extensions: ['sqlite', 'db'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      setState(() => _dbFilePath = file.path);
    }
  }

  Future<void> _pickValidationFile() async {
    const typeGroup = XTypeGroup(
      label: 'Validation File',
      extensions: ['dat'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      setState(() => _validationFilePath = file.path);
    }
  }

  Future<void> _validateAndOpenRustDb() async {
    final l10n = AppLocalizations.of(context)!;

    if (_dbFilePath == null) {
      setState(() => _statusMessage = l10n.selectRustDatabaseFile);
      return;
    }
    if (_validationFilePath == null) {
      setState(() => _statusMessage = l10n.selectValidationFile);
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _statusMessage = l10n.enterPassword);
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = l10n.validatingPassword;
    });

    try {
      final validationFile = File(_validationFilePath!);
      final validationContent = await validationFile.readAsString();
      final Map<String, dynamic> validationJson = jsonDecode(validationContent);
      final validationData = RustValidationData.fromJson(validationJson);

      final Uint8List masterSalt = base64Decode(validationData.masterSaltB64);
      // The ciphertext from validation.dat is (nonce + actual_encrypted_data_of_"PASSWORD_OK")
      final Uint8List testCiphertextWithNonce =
          base64Decode(validationData.testCiphertextB64);

      final decryptedValidationBytes =
          await _rustCryptoService.decryptRustValidationFormat(
        testCiphertextWithNonce,
        _passwordController.text,
        masterSalt,
      );

      if (decryptedValidationBytes != null &&
          utf8.decode(decryptedValidationBytes, allowMalformed: true) ==
              "PASSWORD_OK") {
        setState(() {
          _statusMessage = l10n.passwordValidated;
          _isLoading = false;
        });
        try {
          await _rustDbService.open(_dbFilePath!);
          if (mounted) {
            _successfullyNavigated = true; // Set flag on successful navigation
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RustDbViewerScreen(
                  dbPath: _dbFilePath!,
                  password: _passwordController.text,
                  dbService: _rustDbService,
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _statusMessage = l10n.failedToOpenRustDb(e.toString());
              _isLoading = false;
            });
          }
        }
      } else {
        setState(() {
          _statusMessage = l10n.passwordValidationFailed;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error during Rust DB validation: $e');
      setState(() {
        _statusMessage = l10n.error(e.toString());
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Only close the service if we haven't successfully handed it off
    if (!_successfullyNavigated) {
      _rustDbService.close();
      print(
          'OpenRustDbScreen: Closed DB service because navigation to viewer did not occur or failed before navigation.');
    } else {
      print(
          'OpenRustDbScreen: DB service ownership transferred to RustDbViewerScreen.');
    }
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.openRustDatabase)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.selectRustDatabaseFiles,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          l10n.step1SelectDatabaseFile,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.file_open_outlined),
                          label: Text(l10n.browseForSQLiteFile),
                          onPressed: _pickDbFile,
                        ),
                        if (_dbFilePath != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _dbFilePath!
                                        .split(Platform.pathSeparator)
                                        .last,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        Text(
                          l10n.step2SelectValidationFile,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.verified_user_outlined),
                          label: Text(l10n.browseForValidationFile),
                          onPressed: _pickValidationFile,
                        ),
                        if (_validationFilePath != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _validationFilePath!
                                        .split(Platform.pathSeparator)
                                        .last,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        Text(
                          l10n.step3EnterPassword,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.password,
                            hintText: l10n.enterDatabasePassword,
                          ),
                        ),
                        if (_statusMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _statusMessage!.startsWith('Error') ||
                                      _statusMessage!.contains('failed')
                                  ? Theme.of(context).colorScheme.errorContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _statusMessage!.startsWith('Error') ||
                                          _statusMessage!.contains('failed')
                                      ? Icons.error_outline
                                      : Icons.check_circle_outline,
                                  color: _statusMessage!.startsWith('Error') ||
                                          _statusMessage!.contains('failed')
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _statusMessage!,
                                    style: TextStyle(
                                      color: _statusMessage!
                                                  .startsWith('Error') ||
                                              _statusMessage!.contains('failed')
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.lock_open_rounded),
                            label: Text(l10n.openDatabase),
                            onPressed:
                                _isLoading ? null : _validateAndOpenRustDb,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder for PasswordEntryScreen and MainNotesScreen - your existing screens
class PasswordEntryScreen extends StatefulWidget {
  // From previous steps
  const PasswordEntryScreen({super.key});
  @override
  State<PasswordEntryScreen> createState() => _PasswordEntryScreenState();
}

class _PasswordEntryScreenState extends State<PasswordEntryScreen> {
  final _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Native DB helper
  bool _isLoading = false;
  String? _error;

  Future<void> _unlockApp() async {
    setState(() => _isLoading = true);
    // ... (Your existing unlock logic for native DB) ...
    try {
      final isValid =
          await AuthService().verifyPassword(_passwordController.text);
      if (isValid) {
        await _dbHelper.initializeDatabase(_passwordController.text);
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const MainNotesScreen()));
        }
      } else {
        setState(() {
          _error = AppLocalizations.of(context)!.invalidPassword;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)!.failedToUnlock(e.toString());
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.unlockNativeStorage)),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(l10n.enterPasswordNativeStorage),
          TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.password)),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _unlockApp, child: Text(l10n.unlock)),
        ]),
      )),
    );
  }
}

// MainNotesScreen for the native Dart database
// This is your existing screen. It should not be affected by Rust DB logic directly,
// unless you decide to merge display logic later.
class MainNotesScreen extends StatefulWidget {
  const MainNotesScreen({super.key});
  @override
  State<MainNotesScreen> createState() => _MainNotesScreenState();
}

class _MainNotesScreenState extends State<MainNotesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSearching = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoadingSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    RustCryptoCompatService().selfTestEncryptionDecryption();
    _loadNativeCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNativeCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      _categories = await _dbHelper.getAllCategories();
    } catch (e) {
      print("Error loading native categories: $e");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoadingSearch = true;
    });

    try {
      final results = await _dbHelper.searchNotes(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoadingSearch = false;
        });
      }
    } catch (e) {
      print("Error performing search: $e");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Search error: $e')));
        setState(() => _isLoadingSearch = false);
      }
    }
  }

  Future<void> _createNewCategory() async {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createNewNativeCategory),
        content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.categoryName)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.pop(context, nameController.text.trim());
                }
              },
              child: Text(l10n.create)),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _dbHelper.insertCategory({
        DatabaseHelper.colCategoryId: const Uuid().v4(),
        DatabaseHelper.colCategoryName: result,
        DatabaseHelper.colCategoryCreatedAt: DateTime.now().toIso8601String(),
      });
      _loadNativeCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchNotes,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7)),
                ),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _performSearch(value);
                },
              )
            : Text(l10n.nativeCategories),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                  _searchResults = [];
                }
              });
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.create_new_folder_outlined),
              onPressed: _createNewCategory,
            ),
        ],
      ),
      body: _isSearching
          ? _isLoadingSearch
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? l10n.enterSearchTerm
                            : l10n.noResultsFound,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              result['entry_name'] ?? 'Unnamed Category',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  result['content'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Created: ${DateTime.fromMillisecondsSinceEpoch((result['created_at'] as int) * 1000).toString().split('.')[0]}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryNotesScreen(
                                    categoryId: result['entry_id'],
                                    categoryName: result['entry_name'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )
          : _isLoadingCategories
              ? const Center(child: CircularProgressIndicator())
              : _categories.isEmpty
                  ? Center(child: Text(l10n.noNativeCategoriesYet))
                  : ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return ListTile(
                          title: Text(
                              category[DatabaseHelper.colCategoryName] ??
                                  'Unnamed'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryNotesScreen(
                                  categoryId:
                                      category[DatabaseHelper.colCategoryId],
                                  categoryName:
                                      category[DatabaseHelper.colCategoryName],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  bool? _isNativeDbConfigured;

  @override
  void initState() {
    super.initState();
    _checkNativeDbConfiguration();
  }

  Future<void> _checkNativeDbConfiguration() async {
    final isFirstRunForNative = await AuthService().isFirstRun();
    if (mounted) {
      setState(() => _isNativeDbConfigured = !isFirstRunForNative);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isNativeDbConfigured == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.shield_moon_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.appSubtitle,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.chooseStorageMode,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.storage_rounded),
                          label: Text(l10n.useNativeSecureStorage),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  const NativeStorageOptionsDialog(),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.code_rounded),
                          label: Text(l10n.useRustDatabase),
                          onPressed: () {
                            Navigator.pushNamed(context, '/openRustDb');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isNativeDbConfigured == true
                      ? l10n.nativeStorageConfigured
                      : l10n.nativeStorageNeedsSetup,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
