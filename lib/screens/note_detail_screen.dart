import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as picker;
import '../services/database_helper.dart';
import '../services/individual_note_encryption_service.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

class NoteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> note;
  final String categoryName;

  const NoteDetailScreen({
    super.key,
    required this.note,
    required this.categoryName,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen>
    with WidgetsBindingObserver {
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _isEncrypted = false;
  late Color _backgroundColor;
  late Color _titleColor;
  List<Map<String, dynamic>> _imageAttachments = [];
  bool _isLoadingImages = true;

  // Add timeout tracking
  DateTime? _lastActivityTime;
  static const _inactivityTimeout = Duration(minutes: 5);

  // Add this with other class fields
  DateTime? _lockoutUntil;

  // For image picking
  final List<XFile> _newlyPickedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastActivityTime = DateTime.now();
    _contentController.text = widget.note['content'] ?? '';
    _titleController.text = widget.note['title'] ?? '';
    _backgroundColor = _parseColor(widget.note['noteBackgroundColor']);
    _titleColor = _parseColor(widget.note['noteTitleColor']);

    // Check both the database flag and the content for encryption markers
    _isEncrypted = (widget.note['is_individually_encrypted'] == 1) ||
        (widget.note['is_individually_encrypted'] == true) ||
        _contentController.text.startsWith('🔒ENCRYPTED_NOTE_MARKER🔒');

    print('Note encryption status: $_isEncrypted');
    print('Note content: ${_contentController.text}');
    print(
        'Database encryption flag: ${widget.note['is_individually_encrypted']}');

    // If the note is encrypted, show the decryption dialog immediately
    if (_isEncrypted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDecryptionDialog();
      });
    }

    _loadImageAttachments();

    // Add periodic inactivity check
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkInactivity();
    });
  }

  Color _parseColor(dynamic colorHex) {
    if (colorHex == null) {
      return Colors.white;
    }
    try {
      if (colorHex is int) {
        return Color(colorHex);
      } else if (colorHex is String) {
        if (colorHex.isEmpty) return Colors.white;
        return Color(int.parse(colorHex));
      } else {
        return Colors.white;
      }
    } catch (e) {
      print('Error parsing color: $e');
      return Colors.white;
    }
  }

  Future<void> _showDecryptionDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int failedAttempts = 0;
    const maxAttempts = 3;
    const lockoutDuration = Duration(minutes: 15);

    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final remainingTime = _lockoutUntil!.difference(DateTime.now());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                l10n.tooManyFailedAttempts(remainingTime.inMinutes))),
      );
      return;
    }

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.decryptNote),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.enterPasswordToDecrypt,
                    errorText: failedAttempts > 0 ? l10n.invalidPassword : null,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterThePassword;
                    }
                    return null;
                  },
                ),
                if (failedAttempts > 0)
                  Text(
                    l10n.failedAttempts(failedAttempts, maxAttempts),
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(context).pop(false);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(l10n.decrypt),
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
      setState(() => _isLoading = true);
      try {
        // Remove any existing encryption markers before decrypting
        String contentToDecrypt = _contentController.text;
        while (contentToDecrypt.contains('🔒ENCRYPTED_NOTE_MARKER🔒')) {
          contentToDecrypt =
              contentToDecrypt.replaceAll('🔒ENCRYPTED_NOTE_MARKER🔒', '');
        }

        final decryptedContent = IndividualNoteEncryptionService.decryptNote(
          contentToDecrypt,
          passwordController.text,
        );

        setState(() {
          _contentController.text = decryptedContent;
          _isEncrypted = false;
        });

        await _dbHelper.updateNoteContent(
          widget.note['note_id'],
          decryptedContent,
          '', // password not used for base encryption
          isIndividuallyEncrypted: false,
          encryptionMarker: null,
        );

        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noteDecryptedSuccessfully)),
          );
        }
        failedAttempts = 0; // Reset on success
        _lockoutUntil = null; // Reset lockout
      } catch (e) {
        failedAttempts++;
        if (failedAttempts >= maxAttempts) {
          _lockoutUntil = DateTime.now().add(lockoutDuration);
        }
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.decryptionError(e.toString()))),
          );
          // If decryption fails, return to the previous screen
          Navigator.of(context).pop();
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _showEncryptionDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.encryptNote),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: l10n.passwordLabel),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterPassword;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration:
                      InputDecoration(labelText: l10n.confirmPasswordLabel),
                  obscureText: true,
                  validator: (value) {
                    if (value != passwordController.text) {
                      return l10n.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(l10n.encrypt),
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
      setState(() => _isLoading = true);
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
        // Add a single encryption marker
        final contentWithMarker = '🔒ENCRYPTED_NOTE_MARKER🔒$encryptedContent';
        _contentController.text = contentWithMarker;
        await _dbHelper.updateNoteContent(
          widget.note['note_id'],
          contentWithMarker,
          '', // password not used for base encryption
          isIndividuallyEncrypted: true,
          encryptionMarker:
              IndividualNoteEncryptionService.generateEncryptionMarker(),
        );
        setState(() => _isEncrypted = true);
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noteEncryptedSuccessfully)),
          );
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.encryptionError(e.toString()))),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _pickColor(BuildContext context,
      {required bool forBackground}) async {
    final l10n = AppLocalizations.of(context)!;
    Color pickerColor = forBackground ? _backgroundColor : _titleColor;
    Color newColorHolder = pickerColor;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            forBackground ? l10n.pickNoteBackgroundColor : l10n.pickTitleColor),
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
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text(l10n.select),
            onPressed: () {
              setState(() {
                if (forBackground) {
                  _backgroundColor = newColorHolder;
                } else {
                  _titleColor = newColorHolder;
                }
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _secureClearMemory();
    _titleController.dispose();
    super.dispose();
  }

  // Add secure memory clearing
  void _secureClearMemory() {
    if (_contentController.text.isNotEmpty) {
      // Overwrite the text with random data before clearing
      final random = Random.secure();
      final randomBytes = List<int>.generate(
          _contentController.text.length, (i) => random.nextInt(256));
      _contentController.text = String.fromCharCodes(randomBytes);
    }
    _contentController.clear();
    _contentController.dispose();
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _handleAppBackground();
    }
  }

  // Handle app going to background
  Future<void> _handleAppBackground() async {
    if (_isEncrypted && _contentController.text.isNotEmpty) {
      // Re-encrypt the content if it was decrypted
      final currentContent = _contentController.text;
      if (!currentContent.startsWith('🔒ENCRYPTED_NOTE_MARKER🔒')) {
        await _showEncryptionDialog();
      }
    }
    _secureClearMemory();
  }

  // Add activity tracking
  void _updateLastActivity() {
    _lastActivityTime = DateTime.now();
  }

  // Check for inactivity
  void _checkInactivity() {
    if (_lastActivityTime != null) {
      final now = DateTime.now();
      if (now.difference(_lastActivityTime!) > _inactivityTimeout) {
        _handleAppBackground();
      }
    }
  }

  Future<void> _saveNote() async {
    final l10n = AppLocalizations.of(context)!;
    _updateLastActivity();
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noteContentCannotBeEmpty)));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _dbHelper.updateNoteContent(
        widget.note['note_id'],
        _contentController.text.trim(),
        '', // password not used for base encryption
        title: _titleController.text.trim(),
        backgroundColor: _backgroundColor.value.toString(),
        titleColor: _titleColor.value.toString(),
        isIndividuallyEncrypted: _isEncrypted,
        encryptionMarker:
            _isEncrypted ? widget.note['encryption_marker'] : null,
      );
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.noteUpdated)));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.errorSavingNote(e.toString()))));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteNote() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNote),
        content: Text(
            l10n.deleteNoteConfirmation),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _dbHelper.deleteNote(widget.note['note_id']);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.errorDeletingNote(e.toString()))));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _loadImageAttachments() async {
    try {
      final images =
          await _dbHelper.getNoteImageAttachments(widget.note['note_id']);
      if (mounted) {
        setState(() {
          _imageAttachments = images;
          _isLoadingImages = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _isLoadingImages = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingImages(e.toString()))),
        );
      }
    }
  }

  Future<void> _deleteImage(int imageId) async {
    try {
      await _dbHelper.deleteImageAttachment(imageId);
      await _loadImageAttachments();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.imageDeletedSuccessfully)),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorDeletingImage(e.toString()))),
        );
      }
    }
  }

  void _showImageDialog(Uint8List imageData) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.memory(
              imageData,
              fit: BoxFit.contain,
            ),
            OverflowBar(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.close),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadImage(Uint8List imageData, String imageName) async {
    try {
      final String? selectedDirectory = await getDirectoryPath();
      if (selectedDirectory == null) return;

      final targetPath =
          '$selectedDirectory${Platform.pathSeparator}$imageName';
      final file = File(targetPath);
      await file.writeAsBytes(imageData);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.imageSavedTo(targetPath))),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorDownloadingImage(e.toString()))),
        );
      }
    }
  }

  Widget _buildImageAttachments() {
    if (_isLoadingImages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_imageAttachments.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            l10n.attachedImages,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageAttachments.length,
            itemBuilder: (context, index) {
              final image = _imageAttachments[index];
              final Uint8List imageData = image['image_data'];
              final String imageName = image['image_name'];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _showImageDialog(imageData),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            imageData,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download, size: 20),
                            onPressed: () =>
                                _downloadImage(imageData, imageName),
                            tooltip: 'Download',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () => _deleteImage(image['id']),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() {
        _newlyPickedImages.addAll(images);
      });
      await _savePickedImages();
    }
  }

  Future<void> _savePickedImages() async {
    if (_newlyPickedImages.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      for (final xfile in _newlyPickedImages) {
        final imageName = xfile.name;
        final imageBytes = await xfile.readAsBytes();
        await _dbHelper.addImageAttachment(
            widget.note['note_id'], imageBytes, imageName);
      }
      _newlyPickedImages.clear();
      await _loadImageAttachments();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.imagesAttachedSuccessfully)),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorAttachingImages(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkBackground = _backgroundColor.computeLuminance() < 0.5;
    final contentTextColor = isDarkBackground ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: _backgroundColor.withOpacity(0.8),
        foregroundColor: isDarkBackground ? Colors.white : Colors.black87,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit,
                  color: isDarkBackground ? Colors.white : Colors.black87),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.image),
              tooltip: 'Attach Image(s)',
              onPressed: _pickImages,
            ),
          IconButton(
            icon: Icon(
              _isEncrypted ? Icons.key : Icons.lock_outline,
              color: isDarkBackground ? Colors.white : Colors.black87,
            ),
            onPressed:
                _isEncrypted ? _showDecryptionDialog : _showEncryptionDialog,
            tooltip: _isEncrypted ? l10n.decryptNote : l10n.encryptNote,
          ),
          IconButton(
            icon: Icon(Icons.delete,
                color: isDarkBackground ? Colors.white : Colors.black87),
            onPressed: _deleteNote,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Note Title
                  _isEditing
                      ? TextField(
                          controller: _titleController,
                          style: TextStyle(
                            color: _titleColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.titleLabel,
                            labelStyle:
                                TextStyle(color: _titleColor.withOpacity(0.7)),
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                            ),
                          ),
                        )
                      : Text(
                          _titleController.text.isNotEmpty
                              ? _titleController.text
                              : l10n.untitled,
                          style: TextStyle(
                            color: _titleColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.color_lens),
                        onPressed: () =>
                            _pickColor(context, forBackground: true),
                        tooltip: l10n.changeBackgroundColor,
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_color_text),
                        onPressed: () =>
                            _pickColor(context, forBackground: false),
                        tooltip: l10n.changeTextColor,
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: _isEditing
                        ? TextField(
                            controller: _contentController,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: contentTextColor,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.enterYourNoteHere,
                              hintStyle: TextStyle(
                                color: contentTextColor.withOpacity(0.6),
                              ),
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                            minLines: 10,
                            keyboardType: TextInputType.multiline,
                          )
                        : SelectableText(
                            _contentController.text,
                            style: TextStyle(
                              fontSize: 17,
                              height: 1.5,
                              color: contentTextColor,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _contentController.text =
                                widget.note['content'] ?? '';
                            _titleController.text = widget.note['title'] ?? '';
                            _backgroundColor =
                                _parseColor(widget.note['noteBackgroundColor']);
                            _titleColor =
                                _parseColor(widget.note['noteTitleColor']);
                          });
                        },
                        child: Text(l10n.cancelEdit),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: Text(l10n.saveChanges),
                        onPressed: _saveNote,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildImageAttachments(),
                ],
              ),
            ),
    );
  }

  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list()) {
          if (entity is File) {
            // Securely overwrite file before deletion
            final file = File(entity.path);
            final length = await file.length();
            final random = Random.secure();
            final randomBytes =
                List<int>.generate(length, (i) => random.nextInt(256));
            await file.writeAsBytes(randomBytes);
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Error cleaning up temporary files: $e');
    }
  }
}

class SecurityLogger {
  static final SecurityLogger _instance = SecurityLogger._internal();
  factory SecurityLogger() => _instance;
  SecurityLogger._internal();

  Future<void> logSecurityEvent(String event, {String? details}) async {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = {
      'timestamp': timestamp,
      'event': event,
      'details': details,
    };

    // Store logs securely
    try {
      final prefs = await SharedPreferences.getInstance();
      final logs = prefs.getStringList('security_logs') ?? [];
      logs.add(jsonEncode(logEntry));
      // Keep only last 1000 logs
      if (logs.length > 1000) {
        logs.removeAt(0);
      }
      await prefs.setStringList('security_logs', logs);
    } catch (e) {
      print('Error logging security event: $e');
    }
  }
}
