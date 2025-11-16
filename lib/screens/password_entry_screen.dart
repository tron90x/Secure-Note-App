import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';
import '../l10n/app_localizations.dart';
import 'main_notes_screen.dart';
import 'create_password_screen.dart';
import 'dart:io';

class PasswordEntryScreen extends StatefulWidget {
  final String? customDbPath;

  const PasswordEntryScreen({super.key, this.customDbPath});

  @override
  State<PasswordEntryScreen> createState() => _PasswordEntryScreenState();
}

class _PasswordEntryScreenState extends State<PasswordEntryScreen> {
  final _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;
  String? _error;

  Future<void> _unlockApp() async {
    setState(() => _isLoading = true);
    try {
      final isValid = await AuthService().verifyPassword(
        _passwordController.text,
        customDbPath: widget.customDbPath,
      );
      if (isValid) {
        await _dbHelper.initializeDatabase(
          _passwordController.text,
          customDbPath: widget.customDbPath,
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNotesScreen(),
            ),
          );
        }
      } else {
        setState(() {
          _error = 'Invalid password.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to unlock: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showResetConfirmation() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetDatabase),
        content: Text(
          l10n.resetDatabaseConfirmation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        // Close the current database connection
        await _dbHelper.close();

        // Delete the database file
        final dbPath =
            await _dbHelper.getDatabasePath(customDbPath: widget.customDbPath);
        if (dbPath != null) {
          final dbFile = File(dbPath);
          if (await dbFile.exists()) {
            await dbFile.delete();
          }
        }

        // Reset the shared preferences
        await AuthService().resetPassword(customDbPath: widget.customDbPath);

        if (mounted) {
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
                customDbPath: widget.customDbPath,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          setState(() {
            _error = l10n.failedToResetDatabase(e.toString());
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customDbPath != null
            ? l10n.unlockCustomDatabase
            : l10n.unlockNativeStorage),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.customDbPath != null
                    ? l10n.enterPasswordCustomDb
                    : l10n.enterPasswordNativeStorage,
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.password),
              ),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _unlockApp,
                          child: Text(l10n.unlock),
                        ),
                        if (widget.customDbPath == null) ...[
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed:
                                _isLoading ? null : _showResetConfirmation,
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                            child: Text(l10n.resetDatabase),
                          ),
                        ],
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
