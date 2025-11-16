import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../l10n/app_localizations.dart';

class ThemeSettingsDialog extends StatelessWidget {
  const ThemeSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeService = Provider.of<ThemeService>(context);

    return AlertDialog(
      title: Text(l10n.themeSettings),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.themeMode,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text(l10n.systemTheme),
                icon: const Icon(Icons.brightness_auto),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text(l10n.lightTheme),
                icon: const Icon(Icons.light_mode),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text(l10n.darkTheme),
                icon: const Icon(Icons.dark_mode),
              ),
            ],
            selected: {themeService.themeMode},
            onSelectionChanged: (Set<ThemeMode> selected) {
              themeService.setThemeMode(selected.first);
            },
          ),
          const SizedBox(height: 24),
          Text(
            l10n.automaticDarkMode,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(l10n.enableTimeBasedDarkMode),
            subtitle: Text(l10n.darkModeTimeBased),
            value: themeService.autoDarkTime,
            onChanged: (bool value) {
              themeService.setAutoDarkTime(value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
