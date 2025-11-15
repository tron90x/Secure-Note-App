import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'add_note_screen.dart';
import 'note_detail_screen.dart';

class NoteListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const NoteListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await _dbHelper.getNotesForEntryMonthYear(
        int.parse(widget.categoryId),
        DateTime.now().year,
        DateTime.now().month,
      );
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notes: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return Colors.white;
    }
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No notes yet',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
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
                          if (result == true) {
                            _loadNotes();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Note'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    final backgroundColor = _parseColor(
                        note[DatabaseHelper.colNoteBackgroundColor]);
                    final titleColor =
                        _parseColor(note[DatabaseHelper.colNoteTitleColor]);

                    return Card(
                      color: backgroundColor,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Icon(
                          note['is_individually_encrypted'] == true
                              ? Icons.lock
                              : Icons.description_outlined,
                          color: titleColor,
                        ),
                        title: Text(
                          note[DatabaseHelper.colNoteTitle] ?? 'Untitled',
                          style: TextStyle(
                            color: titleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          note['is_individually_encrypted'] == true
                              ? '[Encrypted Note]'
                              : note[DatabaseHelper.colNoteContent],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: titleColor.withOpacity(0.8),
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
                          if (result == true) {
                            _loadNotes();
                          }
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
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
          if (result == true) {
            _loadNotes();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
