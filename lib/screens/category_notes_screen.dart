import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'add_note_screen.dart';
import 'note_detail_screen.dart';
// Your color helpers

class CategoryNotesScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryNotesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryNotesScreen> createState() => _CategoryNotesScreenState();
}

class _CategoryNotesScreenState extends State<CategoryNotesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final categoryId = int.parse(widget.categoryId);
      final notes = await _dbHelper.getNotesForEntryMonthYear(
        categoryId,
        _selectedDate.year,
        _selectedDate.month,
      );
      if (mounted) {
        setState(() {
          _notes = notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading notes in CategoryNotesScreen: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading notes: $e')));
      }
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedDate =
          DateTime(_selectedDate.year, _selectedDate.month + delta, 1);
    });
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: l10n.addNoteToCategory(widget.categoryName),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNoteScreen(
                    categoryId: widget.categoryId,
                    categoryName: widget.categoryName,
                  ),
                ),
              );
              if (result == true && mounted) {
                _loadNotes(); // Refresh notes if one was added
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _changeMonth(-1)),
                Text(
                  '${DateFormat.MMMM(l10n.localeName).format(DateTime(2000, _selectedDate.month, 1))} ${_selectedDate.year}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _changeMonth(1)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notes_outlined,
                                size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noNotesInCategoryForMonth(
                                widget.categoryName,
                                DateFormat.MMMM(l10n.localeName).format(
                                    DateTime(2000, _selectedDate.month, 1)),
                                _selectedDate.year,
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: Text(l10n.addFirstNote),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddNoteScreen(
                                      categoryId: widget.categoryId,
                                      categoryName: widget.categoryName,
                                    ),
                                  ),
                                );
                                if (result == true && mounted) {
                                  _loadNotes();
                                }
                              },
                            )
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          final note = _notes[index];
                          print(
                              'Building note item: ${note.toString()}'); // Debug log

                          final content = note['content'] as String?;
                          final backgroundColor =
                              _parseColor(note['noteBackgroundColor']);
                          final titleColor =
                              _parseColor(note['noteTitleColor']);
                          final bool isDarkBackground =
                              backgroundColor.computeLuminance() < 0.5;
                          final Color contentTextColor =
                              isDarkBackground ? Colors.white : Colors.black87;

                          return Card(
                            color: backgroundColor,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                note['title'] ?? 'Untitled',
                                style: TextStyle(
                                  color: titleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                content ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: contentTextColor,
                                ),
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NoteDetailScreen(
                                      note: note,
                                      categoryName: widget.categoryName,
                                    ),
                                  ),
                                );
                                if (result == true && mounted) {
                                  _loadNotes(); // Refresh if note was updated or deleted
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return Colors.white;
    }
    try {
      // The color value is stored as a string representation of the integer
      return Color(int.parse(colorHex));
    } catch (e) {
      print('Error parsing color: $e');
      return Colors.white;
    }
  }
}
