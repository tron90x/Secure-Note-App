import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Import main.dart to access the original StartupScreen
import '../services/localization_service.dart';
import '../l10n/app_localizations.dart';

class FakeErrorScreen extends StatefulWidget {
  const FakeErrorScreen({super.key});

  @override
  State<FakeErrorScreen> createState() => _FakeErrorScreenState();
}

class _FakeErrorScreenState extends State<FakeErrorScreen> {
  bool _isLoading = false;
  int _buttonClickCount = 0;
  bool _showLanguageSelector = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleButtonClick() {
    setState(() {
      _buttonClickCount++;
      if (_buttonClickCount >= 6) {
        _isLoading = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StartupScreen()),
        );
      }
    });
  }

  void _toggleLanguageSelector() {
    setState(() {
      _showLanguageSelector = !_showLanguageSelector;
    });
  }

  void _selectLanguage(Locale locale) {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    localizationService.setLanguage(locale);
    setState(() {
      _showLanguageSelector = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localizationService = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade50,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguageSelector,
            tooltip: l10n.selectLanguage,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade700,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.applicationError,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.unknownErrorOccurred,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.red.shade700,
                    ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleButtonClick,
                icon: const Icon(Icons.close),
                label: Text(l10n.closeApplication),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
              if (_showLanguageSelector) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.selectLanguage,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ...AppLocalizations.supportedLocales.map((locale) {
                          final isSelected = localizationService.currentLocale.languageCode == locale.languageCode;
                          return ListTile(
                            leading: Radio<Locale>(
                              value: locale,
                              groupValue: localizationService.currentLocale,
                              onChanged: (Locale? value) {
                                if (value != null) {
                                  _selectLanguage(value);
                                }
                              },
                            ),
                            title: Text(localizationService.getLanguageName(locale.languageCode)),
                            onTap: () => _selectLanguage(locale),
                            selected: isSelected,
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
