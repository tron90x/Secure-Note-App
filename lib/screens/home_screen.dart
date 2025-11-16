import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'category_notes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myNotes),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.welcomeToMyNotes,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.yourPersonalNoteApplication,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to a sample category
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryNotesScreen(
                      categoryId: '1',
                      categoryName: 'General',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.notes),
              label: Text(l10n.viewNotes),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
