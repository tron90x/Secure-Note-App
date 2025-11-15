import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'category_notes_screen.dart';
import 'note_detail_screen.dart';
import 'fake_error_screen.dart'; // Updated import
import 'theme_settings_dialog.dart';
import 'dart:async';

class MainNotesScreen extends StatefulWidget {
  const MainNotesScreen({super.key});

  @override
  State<MainNotesScreen> createState() => _MainNotesScreenState();
}

class _MainNotesScreenState extends State<MainNotesScreen>
    with WidgetsBindingObserver {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;
  List<Map<String, dynamic>> _entries = [];
  bool _isSearching = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoadingSearch = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;
  Timer? _inactivityTimer;
  int _remainingSeconds = 180; // 3 minutes
  static const int _showTimerThreshold =
      30; // Show timer when 30 seconds remain

  // Filter states
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategoryId;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    print('MainNotesScreen initialized');
    _loadEntries();
    WidgetsBinding.instance.addObserver(this);
    _startInactivityTimer();
  }

  @override
  void dispose() {
    print('MainNotesScreen disposed');
    _searchController.dispose();
    _inactivityTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('App lifecycle state changed: $state');
    if (state == AppLifecycleState.resumed) {
      _startInactivityTimer();
    }
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _remainingSeconds = 180; // Reset to 3 minutes
    _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const FakeErrorScreen()),
              (route) => false,
            );
          }
        }
      });
    });
  }

  void _handleUserActivity() {
    print('User activity detected');
    _startInactivityTimer();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await _dbHelper.getAllEntries();
      if (mounted) {
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading entries: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      final results = await _dbHelper.searchNotes(
        query,
        startDate: _startDate,
        endDate: _endDate,
        categoryId: _selectedCategoryId,
      );
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

  Future<void> _selectDateRange() async {
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (dateRange != null) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
      });
      if (_searchQuery.isNotEmpty) {
        _performSearch(_searchQuery);
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedCategoryId = null;
    });
    if (_searchQuery.isNotEmpty) {
      _performSearch(_searchQuery);
    }
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      children: [
        if (_startDate != null || _endDate != null)
          FilterChip(
            label: Text(
              'Date: ${_startDate?.toString().split(' ')[0] ?? 'Any'} - ${_endDate?.toString().split(' ')[0] ?? 'Any'}',
            ),
            selected: true,
            onSelected: (bool selected) {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              if (_searchQuery.isNotEmpty) {
                _performSearch(_searchQuery);
              }
            },
            onDeleted: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              if (_searchQuery.isNotEmpty) {
                _performSearch(_searchQuery);
              }
            },
          ),
        if (_selectedCategoryId != null)
          FilterChip(
            label: Text(
              'Category: ${_entries.firstWhere((e) => e['id'].toString() == _selectedCategoryId)['decrypted_name']}',
            ),
            selected: true,
            onSelected: (bool selected) {
              setState(() {
                _selectedCategoryId = null;
              });
              if (_searchQuery.isNotEmpty) {
                _performSearch(_searchQuery);
              }
            },
            onDeleted: () {
              setState(() {
                _selectedCategoryId = null;
              });
              if (_searchQuery.isNotEmpty) {
                _performSearch(_searchQuery);
              }
            },
          ),
      ],
    );
  }

  Widget _buildFilterPanel() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Filters',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _showFilters = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _startDate != null && _endDate != null
                          ? '${_startDate!.toString().split(' ')[0]} - ${_endDate!.toString().split(' ')[0]}'
                          : 'Select Date Range',
                    ),
                    onPressed: _selectDateRange,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                    if (_searchQuery.isNotEmpty) {
                      _performSearch(_searchQuery);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Filter by Category',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Categories'),
                ),
                ..._entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry['id'].toString(),
                    child: Text(entry['decrypted_name'] as String),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
                if (_searchQuery.isNotEmpty) {
                  _performSearch(_searchQuery);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All Filters'),
                  onPressed: _clearFilters,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addEntry() async {
    final entryNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Entry'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: entryNameController,
            decoration: const InputDecoration(
              labelText: 'Entry Name',
              hintText: 'Enter a name for your entry',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, entryNameController.text.trim());
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await _dbHelper.insertEntry(result, '');
        _loadEntries();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating entry: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteEntry(Map<String, dynamic> entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
            'Are you sure you want to delete "${entry['decrypted_name']}"? This will also delete all notes in this entry.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteEntry(entry['id']);
        _loadEntries();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting entry: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleUserActivity(),
      onHover: (_) => _handleUserActivity(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: _isSearching
                    ? TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search notes...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7)),
                        ),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                          _performSearch(value);
                          _handleUserActivity();
                        },
                      )
                    : const Text('Native Categories'),
              ),
              if (_remainingSeconds <= _showTimerThreshold) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _remainingSeconds <= 10 ? Colors.red : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_remainingSeconds',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.palette_outlined),
              tooltip: 'Theme Settings',
              onPressed: () {
                _handleUserActivity();
                showDialog(
                  context: context,
                  builder: (context) => const ThemeSettingsDialog(),
                );
              },
            ),
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              tooltip:
                  _isGridView ? 'Switch to List View' : 'Switch to Grid View',
              onPressed: () {
                _handleUserActivity();
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Return to Welcome Screen',
              onPressed: () {
                _handleUserActivity();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FakeErrorScreen()),
                  (route) => false,
                );
              },
            ),
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                _handleUserActivity();
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
                onPressed: () {
                  _handleUserActivity();
                  _addEntry();
                },
              ),
          ],
        ),
        body: _isSearching
            ? Column(
                children: [
                  if (_showFilters) _buildFilterPanel(),
                  if (_startDate != null ||
                      _endDate != null ||
                      _selectedCategoryId != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildFilterChips(),
                    ),
                  Expanded(
                    child: _isLoadingSearch
                        ? const Center(child: CircularProgressIndicator())
                        : _searchResults.isEmpty
                            ? Center(
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? 'Enter a search term'
                                      : 'No results found',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              )
                            : _isGridView
                                ? GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 1.0,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                    itemCount: _searchResults.length,
                                    itemBuilder: (context, index) {
                                      final result = _searchResults[index];
                                      return Card(
                                        child: InkWell(
                                          onTap: () {
                                            _handleUserActivity();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NoteDetailScreen(
                                                  note: result,
                                                  categoryName:
                                                      result['entry_name'] ??
                                                          '',
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  result['entry_name'] ??
                                                      'Unnamed Category',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Expanded(
                                                  child: Text(
                                                    result['content'] ?? '',
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  (() {
                                                    int createdAt;
                                                    if (result['created_at']
                                                        is int) {
                                                      createdAt =
                                                          result['created_at'];
                                                    } else if (result[
                                                            'created_at']
                                                        is String) {
                                                      createdAt = int.tryParse(
                                                              result[
                                                                  'created_at']) ??
                                                          0;
                                                    } else {
                                                      createdAt = 0;
                                                    }
                                                    return 'Created: ${DateTime.fromMillisecondsSinceEpoch(createdAt * 1000).toString().split('.')[0]}';
                                                  })(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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
                                            result['entry_name'] ??
                                                'Unnamed Category',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 4),
                                              Text(
                                                result['content'] ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                (() {
                                                  int createdAt;
                                                  if (result['created_at']
                                                      is int) {
                                                    createdAt =
                                                        result['created_at'];
                                                  } else if (result[
                                                      'created_at'] is String) {
                                                    createdAt = int.tryParse(
                                                            result[
                                                                'created_at']) ??
                                                        0;
                                                  } else {
                                                    createdAt = 0;
                                                  }
                                                  return 'Created: ${DateTime.fromMillisecondsSinceEpoch(createdAt * 1000).toString().split('.')[0]}';
                                                })(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            _handleUserActivity();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NoteDetailScreen(
                                                  note: result,
                                                  categoryName:
                                                      result['entry_name'] ??
                                                          '',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ],
              )
            : _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.note_add_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 16),
                            Text(
                              'No entries yet',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to create your first entry',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                _handleUserActivity();
                                _addEntry();
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Create First Entry'),
                            ),
                          ],
                        ),
                      )
                    : _isGridView
                        ? GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.0,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _entries.length,
                            itemBuilder: (context, index) {
                              final entry = _entries[index];
                              return Card(
                                child: InkWell(
                                  onTap: () {
                                    _handleUserActivity();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CategoryNotesScreen(
                                          categoryId: entry['id'].toString(),
                                          categoryName:
                                              entry['decrypted_name'] as String,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.folder_outlined,
                                          size: 48,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          entry['decrypted_name'] ?? 'Unnamed',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount: _entries.length,
                            itemBuilder: (context, index) {
                              final entry = _entries[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  title: Text(
                                    entry['decrypted_name'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Last modified: ${DateTime.fromMillisecondsSinceEpoch(entry['last_modified'] * 1000).toString().substring(0, 16)}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    color: Colors.red,
                                    onPressed: () {
                                      _handleUserActivity();
                                      _deleteEntry(entry);
                                    },
                                    tooltip: 'Delete Entry',
                                  ),
                                  onTap: () {
                                    _handleUserActivity();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CategoryNotesScreen(
                                          categoryId: entry['id'].toString(),
                                          categoryName:
                                              entry['decrypted_name'] as String,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
        floatingActionButton: !_isSearching
            ? FloatingActionButton(
                onPressed: () {
                  _handleUserActivity();
                  _addEntry();
                },
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
