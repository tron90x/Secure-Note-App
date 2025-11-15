import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';

class CreatePasswordScreen extends StatefulWidget {
  final Function(String password) onPasswordCreated;
  final String? customDbPath;

  const CreatePasswordScreen({
    super.key,
    required this.onPasswordCreated,
    this.customDbPath,
  });

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorText;

  Future<void> _submitPassword() async {
    setState(() {
      _errorText = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final password = _passwordController.text;

      try {
        final authSuccess = await AuthService().setupPassword(
          password,
          customDbPath: widget.customDbPath,
        );
        if (authSuccess) {
          await DatabaseHelper().initializeDatabase(
            password,
            customDbPath: widget.customDbPath,
          );
          print("Database initialized after password creation.");

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .passwordCreatedSuccess),
              ),
            );
            widget.onPasswordCreated(password);
          }
        } else {
          setState(() => _errorText =
              AppLocalizations.of(context)!.failedToSetPassword);
        }
      } catch (e) {
        print("Error during password setup or DB init: $e");
        setState(() =>
            _errorText = AppLocalizations.of(context)!.genericError(e.toString()));
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customDbPath != null
            ? l10n.createPasswordForCustomDatabaseTitle
            : l10n.createSecurePasswordTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.customDbPath != null
                      ? l10n.createPasswordLeadCustom
                      : l10n.createPasswordLead,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.passwordLabel,
                    hintText: l10n.passwordHint,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterPassword;
                    }
                    if (value.length < 6) {
                      return l10n.minPasswordLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPasswordLabel,
                    hintText: l10n.confirmPasswordHint,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseConfirmPassword;
                    }
                    if (value != _passwordController.text) {
                      return l10n.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitPassword,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(l10n.create),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
