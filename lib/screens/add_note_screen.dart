import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as picker;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../services/individual_note_encryption_service.dart';

class AddNoteScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const AddNoteScreen({super.key, this.categoryId, this.categoryName});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _dbHelper = DatabaseHelper();

  Color _currentNoteBackgroundColor = Colors.yellow[100]!;
  Color _currentTitleColor = Colors.black;
  bool _isEncrypted = false;
  String? _encryptionMarker;

  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      _selectedCategoryId = widget.categoryId;
    } else {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categories = await _dbHelper.getAllCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          if (_categories.isNotEmpty && _selectedCategoryId == null) {
            // _selectedCategoryId = _categories.first[DatabaseHelper.colCategoryId];
          }
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print("Error loading categories in AddNoteScreen: $e");
      if (mounted) {
        setState(() => _isLoadingCategories = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  Future<void> _pickColor(BuildContext context,
      {required bool forBackground}) async {
    Color pickerColor =
        forBackground ? _currentNoteBackgroundColor : _currentTitleColor;
    Color newColorHolder = pickerColor;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            forBackground ? 'Pick Note Background Color' : 'Pick Title Color'),
        content: SingleChildScrollView(
          child: picker.ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => newColorHolder = color,
            colorPickerWidth: 300.0,
            pickerAreaHeightPercent: 0.7,
            enableAlpha: true,
            displayThumbColor: true,
            paletteType: picker.PaletteType.hsvWithHue,
            pickerAreaBorderRadius:
                const BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Select'),
            onPressed: () {
              setState(() {
                if (forBackground) {
                  _currentNoteBackgroundColor = newColorHolder;
                } else {
                  _currentTitleColor = newColorHolder;
                }
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEncryptionDialog() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter some content before encrypting')),
      );
      return;
    }

    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Encrypt Note'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Encrypt'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        // Remove any existing encryption markers before encrypting
        String contentToEncrypt = _contentController.text;
        while (contentToEncrypt.contains('🔒ENCRYPTED_NOTE_MARKER🔒')) {
          contentToEncrypt =
              contentToEncrypt.replaceAll('🔒ENCRYPTED_NOTE_MARKER🔒', '');
        }

        final encryptedContent = IndividualNoteEncryptionService.encryptNote(
          contentToEncrypt,
          passwordController.text,
        );

        setState(() {
          _contentController.text =
              '🔒ENCRYPTED_NOTE_MARKER🔒$encryptedContent';
          _isEncrypted = true;
          _encryptionMarker =
              IndividualNoteEncryptionService.generateEncryptionMarker();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note encrypted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 80,
    );

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildImagePreview() {
    if (_selectedImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImages[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 12,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    try {
      final noteId = await _dbHelper.insertNote(
        int.parse(_selectedCategoryId!),
        _contentController.text,
        '', // password not used for base encryption
        title: _titleController.text.trim(),
        backgroundColor: _currentNoteBackgroundColor.value.toRadixString(16),
        titleColor: _currentTitleColor.value.toRadixString(16),
        isIndividuallyEncrypted: _isEncrypted,
        encryptionMarker: _encryptionMarker,
      );

      // Save image attachments
      for (var image in _selectedImages) {
        final imageName = image.path.split(Platform.pathSeparator).last;
        final imageBytes = await image.readAsBytes();
        await _dbHelper.addImageAttachment(noteId, imageBytes, imageName);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkBackground =
        _currentNoteBackgroundColor.computeLuminance() < 0.5;
    final Color contentTextColor =
        isDarkBackground ? Colors.white : Colors.black87;

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName != null
            ? l10n.noteInCategory(widget.categoryName!)
            : l10n.addNewNote),
        actions: [
          IconButton(
            icon: Icon(
              _isEncrypted ? Icons.key : Icons.lock_outline,
              color: isDarkBackground ? Colors.white : Colors.black87,
            ),
            onPressed: _showEncryptionDialog,
            tooltip: _isEncrypted ? l10n.noteIsEncrypted : l10n.encryptNote,
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _pickImages,
          ),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveNote)
        ],
      ),
      body: _isLoadingCategories && widget.categoryId == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Category Dropdown (if categoryId not passed via widget)
                  if (widget.categoryId == null && _categories.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: l10n.categoryLabel,
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category[DatabaseHelper.colCategoryId],
                          child: Text(
                              category[DatabaseHelper.colCategoryName] ??
                                  l10n.unnamed),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    validator: (value) =>
                        value == null ? l10n.pleaseSelectCategory : null,
                    )
                  else if (widget.categoryName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(l10n.categoryColon(widget.categoryName!),
                          style: Theme.of(context).textTheme.titleMedium),
                    ),

                  // Color Picker Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.color_lens_outlined,
                              color: isDarkBackground
                                  ? Colors.white
                                  : Colors.black),
                          label: Text(l10n.background,
                              style: TextStyle(
                                  color: isDarkBackground
                                      ? Colors.white
                                      : Colors.black)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentNoteBackgroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () =>
                              _pickColor(context, forBackground: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.format_color_text,
                              color: _currentTitleColor.computeLuminance() < 0.5
                                  ? Colors.white
                                  : Colors.black),
                          label: Text(l10n.titleColor,
                              style: TextStyle(
                                  color: _currentTitleColor.computeLuminance() <
                                          0.5
                                      ? Colors.white
                                      : Colors.black)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentTitleColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () =>
                              _pickColor(context, forBackground: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title Field
                  TextField(
                    controller: _titleController,
                    style: TextStyle(
                        color: _currentTitleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    decoration: InputDecoration(
                      labelText: l10n.titleOptional,
                      labelStyle:
                          TextStyle(color: _currentTitleColor.withOpacity(0.7)),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Content Field
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: _currentNoteBackgroundColor,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _contentController,
                      style: TextStyle(color: contentTextColor, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: l10n.enterYourNoteHere,
                        hintStyle:
                            TextStyle(color: contentTextColor.withOpacity(0.6)),
                        border: InputBorder.none,
                      ),
                      maxLines: 15,
                      minLines: 5,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildImagePreview(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(l10n.saveNote),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16)),
                    onPressed: _saveNote,
                  )
                ],
              ),
            ),
    );
  }
}
