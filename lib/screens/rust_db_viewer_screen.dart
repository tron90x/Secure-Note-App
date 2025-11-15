import 'package:flutter/material.dart';
import 'package:path/path.dart'
    as p; // For path operations (used for basename in AppBar)
import 'dart:math';
// import 'dart:typed_data'; // May not be needed directly if service handles all byte conversions
// import 'dart:io' show Platform; // No longer needed for factory selection here

import 'package:note_app/services/rust_mode_db_service.dart'; // Import the new service

// Define simple data structures for Rust DB content
class RustEntry {
  final int id;
  final String name; // Decrypted name
  final int lastModified;

  RustEntry({required this.id, required this.name, required this.lastModified});
}

class RustNote {
  final int noteId;
  final int entryId;
  final String content; // Decrypted content
  final int creationTimestamp;

  RustNote(
      {required this.noteId,
      required this.entryId,
      required this.content,
      required this.creationTimestamp});
}

class RustDbViewerScreen extends StatefulWidget {
  final String dbPath; // Still useful for AppBar title
  final String password; // Needed for service calls
  final RustModeDbService dbService; // The service instance

  const RustDbViewerScreen({
    super.key,
    required this.dbPath,
    required this.password,
    required this.dbService,
  });

  @override
  State<RustDbViewerScreen> createState() => _RustDbViewerScreenState();
}

class _RustDbViewerScreenState extends State<RustDbViewerScreen> {
  bool _isLoading = true;
  String? _error;
  List<RustEntry> _entries = [];
  RustEntry? _selectedEntry;
  List<RustNote> _currentNotes = [];
  DateTime _selectedDate = DateTime.now(); // For note filtering

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _loadRustEntries();
    } catch (e) {
      print('Error loading initial Rust DB data: $e');
      if (mounted) setState(() => _error = 'Failed to load initial data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRustEntries({bool selectFirst = true}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final List<Map<String, dynamic>> entryMaps =
          await widget.dbService.getAllEntries(widget.password);
      final List<RustEntry> loadedEntries = entryMaps.map((map) {
        return RustEntry(
          id: map[RustModeDbService.colEntryId] as int,
          name: map['decrypted_name'] as String? ?? '[Error/Missing Name]',
          lastModified: map[RustModeDbService.colEntryLastModified] as int,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _entries = loadedEntries;
          if (selectFirst && _entries.isNotEmpty) {
            _selectedEntry = _entries.first;
            _loadRustNotesForSelectedEntryAndDate();
          } else if (_entries.isEmpty) {
            _selectedEntry = null;
            _currentNotes = [];
          }
        });
      }
    } catch (e) {
      print('Error loading Rust entries: $e');
      if (mounted) {
        setState(() => _error = 'Failed to load entries: $e');
      }
    } finally {
      if (!(_selectedEntry != null && selectFirst)) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadRustNotesForSelectedEntryAndDate() async {
    if (_selectedEntry == null) {
      if (mounted) setState(() => _currentNotes = []);
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final List<Map<String, dynamic>> noteMaps =
          await widget.dbService.getNotesForEntryMonthYear(
        _selectedEntry!.id,
        _selectedDate.year,
        _selectedDate.month,
        widget.password,
      );

      final List<RustNote> loadedNotes = noteMaps.map((map) {
        return RustNote(
          noteId: map[RustModeDbService.colNoteId] as int,
          entryId: map[RustModeDbService.colNoteEntryId] as int,
          content:
              map['decrypted_content'] as String? ?? '[Error/Missing Content]',
          creationTimestamp:
              map[RustModeDbService.colNoteCreationTimestamp] as int,
        );
      }).toList();

      if (mounted) setState(() => _currentNotes = loadedNotes);
    } catch (e) {
      print('Error loading Rust notes for entry ${_selectedEntry!.id}: $e');
      if (mounted) {
        setState(() => _error = 'Failed to load notes: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedDate =
          DateTime(_selectedDate.year, _selectedDate.month + delta, 1);
    });
    _loadRustNotesForSelectedEntryAndDate();
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

  Future<void> _addEntry() async {
    final entryNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final newEntryName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Entry'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: entryNameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Entry Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Entry name cannot be empty.';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(entryNameController.text.trim());
                }
              },
            ),
          ],
        );
      },
    );

    if (newEntryName != null && newEntryName.isNotEmpty) {
      try {
        final newEntryId =
            await widget.dbService.insertEntry(newEntryName, widget.password);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Entry "$newEntryName" added with ID: $newEntryId.')),
        );
        await _loadRustEntries(selectFirst: false);
      } catch (e) {
        print('Error adding entry: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to add entry: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _editEntry(RustEntry entry) async {
    final entryNameController = TextEditingController(text: entry.name);
    final formKey = GlobalKey<FormState>();

    final updatedEntryName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Entry "${entry.name}"'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: entryNameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'New Entry Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Entry name cannot be empty.';
                }
                if (value.trim() == entry.name) {
                  return 'Please enter a different name.';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(entryNameController.text.trim());
                }
              },
            ),
          ],
        );
      },
    );

    if (updatedEntryName != null &&
        updatedEntryName.isNotEmpty &&
        updatedEntryName != entry.name) {
      final String originalName =
          entry.name; // Store original name for snackbar
      final int editedEntryId = entry.id; // Store ID of the entry being edited

      try {
        await widget.dbService
            .updateEntryName(editedEntryId, updatedEntryName, widget.password);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Entry "$originalName" updated to "$updatedEntryName".')),
        );

        final int? previousSelectedId =
            _selectedEntry?.id; // ID of entry selected before edit/reload
        await _loadRustEntries(
            selectFirst:
                false); // Reload entries, _selectedEntry might be stale

        RustEntry? entryToSelectAfterEdit;
        // 1. Try to find the entry that was just edited
        try {
          entryToSelectAfterEdit =
              _entries.firstWhere((e) => e.id == editedEntryId);
        } catch (e) {
          // Not found (should be rare after an update)
          entryToSelectAfterEdit = null;
        }

        // 2. If edited entry not found (or to preserve selection), try to find the previously selected entry
        if (entryToSelectAfterEdit == null && previousSelectedId != null) {
          try {
            entryToSelectAfterEdit =
                _entries.firstWhere((e) => e.id == previousSelectedId);
          } catch (e) {
            // Not found
            entryToSelectAfterEdit = null;
          }
        }

        // 3. If still nothing, and entries exist, pick the first one
        if (entryToSelectAfterEdit == null && _entries.isNotEmpty) {
          entryToSelectAfterEdit = _entries.first;
        }

        setState(() {
          _selectedEntry = entryToSelectAfterEdit;
        });

        if (_selectedEntry != null) {
          _loadRustNotesForSelectedEntryAndDate();
        } else {
          // Ensure notes are cleared if no entry is selected
          if (mounted) {
            setState(() {
              _currentNotes = [];
            });
          }
        }
      } catch (e) {
        print('Error updating entry: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update entry: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _deleteEntry(RustEntry entry) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Entry?'),
            content: Text(
                'Are you sure you want to delete "${entry.name}" and all its notes? This cannot be undone.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await widget.dbService.deleteEntry(entry.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Entry "${entry.name}" deleted')));
        _loadRustEntries(
            selectFirst: _entries.length > 1 && _selectedEntry?.id != entry.id);
      } catch (e) {
        print('Error deleting entry: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error deleting entry: $e')));
      }
    }
  }

  Future<void> _addNote() async {
    if (_selectedEntry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an entry first.')),
      );
      return;
    }

    final newNoteContentController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final bool? noteAdded = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Note to "${_selectedEntry!.name}"'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: newNoteContentController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Note Content'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Note content cannot be empty.';
                }
                return null;
              },
              maxLines: 5,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Add Note'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true); // Signal to proceed
                }
              },
            ),
          ],
        );
      },
    );

    if (noteAdded == true && newNoteContentController.text.trim().isNotEmpty) {
      try {
        await widget.dbService.insertNote(
          _selectedEntry!.id,
          newNoteContentController.text.trim(),
          widget.password,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Note added successfully!')), // Potentially still encrypted
        );
        await _loadRustNotesForSelectedEntryAndDate(); // Refresh notes list
      } catch (e) {
        print('Error adding note: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add note: $e')),
        );
      }
    }
    newNoteContentController.dispose();
  }

  void _editNote(RustNote note) {
    print('TODO: Edit note ${note.noteId}');
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('TODO: Edit Note ${note.noteId}')));
  }

  void _deleteNote(RustNote note) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Note?'),
            content: const Text(
                'Are you sure you want to delete this note? This cannot be undone.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await widget.dbService.deleteNote(note.noteId);
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Note deleted')));
        _loadRustNotesForSelectedEntryAndDate();
      } catch (e) {
        print('Error deleting note: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error deleting note: $e')));
      }
    }
  }

  void _selectEntry(RustEntry entry) {
    setState(() {
      _selectedEntry = entry;
    });
    _loadRustNotesForSelectedEntryAndDate();
  }

  @override
  void dispose() {
    print('RustDbViewerScreen: Disposing and closing DB service.');
    widget.dbService.close().catchError((e) {
      print('Error closing DB service from RustDbViewerScreen: $e');
    });
    // _newEntryNameController and _newNoteContentController are local to their dialog methods (e.g., _addEntry, _addNote)
    // and are typically managed/disposed there or handled by Flutter's dialog lifecycle.
    // They are not instance members of _RustDbViewerScreenState.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rust DB: ${p.basename(widget.dbPath)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRustEntries,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading && _entries.isEmpty && _selectedEntry == null
          ? const Center(
              child: CircularProgressIndicator(
                  semanticsLabel: "Loading database..."))
          : _error != null
              ? Center(
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildEntriesList(),
                    ),
                    const Divider(thickness: 2),
                    if (_selectedEntry != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () => _changeMonth(-1),
                              tooltip: 'Previous Month',
                            ),
                            Text(
                              'Notes for "${_selectedEntry!.name}"\n${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () => _changeMonth(1),
                              tooltip: 'Next Month',
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      flex: 3,
                      child: _buildNotesList(),
                    ),
                  ],
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'newEntry',
            onPressed: _addEntry,
            tooltip: 'Add New Entry',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          if (_selectedEntry != null)
            FloatingActionButton(
              heroTag: 'newNote',
              onPressed: _addNote,
              tooltip: 'Add New Note',
              child: const Icon(Icons.note_add),
            ),
        ],
      ),
    );
  }

  Widget _buildEntriesList() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Entries',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: _entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No entries found',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      final isSelected = _selectedEntry?.id == entry.id;
                      return Card(
                        elevation: isSelected ? 4.0 : 1.0,
                        shape: RoundedRectangleBorder(
                          side: isSelected
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1.5)
                              : BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            Icons.folder,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          title: Text(
                            entry.name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.3),
                          onTap: () => _selectEntry(entry),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editEntry(entry),
                                tooltip: 'Edit Entry',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteEntry(entry),
                                tooltip: 'Delete Entry',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Notes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: _currentNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notes found for this month',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _currentNotes.length,
                    itemBuilder: (context, index) {
                      final note = _currentNotes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            Icons.description_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          title: Text(
                            note.content.split('\n').first,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'ID: ${note.noteId} | Created: ${DateTime.fromMillisecondsSinceEpoch(note.creationTimestamp * 1000).toLocal().toString().substring(0, 10)}'
                            '${note.content.contains("\n") ? "\n${note.content.substring(note.content.indexOf("\n") + 1).replaceAll("\n", " ").substring(0, min(note.content.length - note.content.indexOf("\n") - 1, 50))}..." : ""}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_note_outlined,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _editNote(note),
                                tooltip: 'Edit Note',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_forever_outlined,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteNote(note),
                                tooltip: 'Delete Note',
                              ),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Note ID: ${note.noteId}'),
                                content: Scrollbar(
                                  child: SingleChildScrollView(
                                    child: SelectableText(note.content),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
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
}
