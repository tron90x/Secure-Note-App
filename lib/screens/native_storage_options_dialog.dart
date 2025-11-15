import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import '../services/auth_service.dart';
import 'create_password_screen.dart';
import 'password_entry_screen.dart';

class NativeStorageOptionsDialog extends StatelessWidget {
  const NativeStorageOptionsDialog({super.key});

  Future<void> _handleDefaultDatabase(BuildContext context) async {
    Navigator.pop(context); // Close the dialog
    final isFirstRun = await AuthService().isFirstRun();
    if (isFirstRun) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreatePasswordScreen(
              onPasswordCreated: (password) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PasswordEntryScreen(),
                  ),
                );
              },
            ),
          ),
        );
      }
    } else {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PasswordEntryScreen(),
          ),
        );
      }
    }
  }

  Future<void> _handleOpenExistingDatabase(BuildContext context) async {
    final directory = await getDirectoryPath();
    if (directory == null) return;

    final prefsFile = File('$directory/shared_preferences.json');
    if (!await prefsFile.exists()) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.selectedDirMissingPrefs),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Look for any .db file in the directory
    final dir = Directory(directory);
    final dbFiles = await dir
        .list()
        .where((entity) => entity.path.endsWith('.db'))
        .toList();

    if (dbFiles.isEmpty) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noDbFileFound),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Use the first .db file found
    final dbFile = dbFiles.first.path;
    print('Found database file: $dbFile');

    // Check if it's a first run for this database
    final isFirstRun = await AuthService().isFirstRun(customDbPath: directory);
    if (isFirstRun) {
      if (context.mounted) {
        Navigator.pop(context); // Close the dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreatePasswordScreen(
              onPasswordCreated: (password) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PasswordEntryScreen(
                      customDbPath: directory,
                    ),
                  ),
                );
              },
              customDbPath: directory,
            ),
          ),
        );
      }
    } else {
      Navigator.pop(context); // Close the dialog
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordEntryScreen(
              customDbPath: directory,
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleCreateDatabase(BuildContext context) async {
    final directory = await getDirectoryPath();
    if (directory == null) return;

    final noteAppDir = Directory('$directory/note_app');
    if (!await noteAppDir.exists()) {
      await noteAppDir.create(recursive: true);
    }

    Navigator.pop(context); // Close the dialog
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePasswordScreen(
            customDbPath: noteAppDir.path,
            onPasswordCreated: (password) {
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.databaseCreatedTitle),
                    content: Text(AppLocalizations.of(context)!.openNewDatabaseQuestion),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PasswordEntryScreen(
                                customDbPath: noteAppDir.path,
                              ),
                            ),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.openDatabaseAction),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NativeStorageOptionsDialog(),
                            ),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.backToOptions),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.nativeOptionsTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.storage),
              label: Text(l10n.createOrOpenDefaultDatabase),
              onPressed: () => _handleDefaultDatabase(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: Text(l10n.openExistingDatabase),
              onPressed: () => _handleOpenExistingDatabase(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.create_new_folder),
              label: Text(l10n.createNewDatabase),
              onPressed: () => _handleCreateDatabase(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
