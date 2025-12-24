import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/diary.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Clean and minimal editor screen with auto-save
class EditorScreen extends StatefulWidget {
  final Diary diary;

  const EditorScreen({super.key, required this.diary});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late FocusNode _contentFocusNode;
  late Diary _diary;

  bool _hasChanges = false;
  bool _isSaving = false;
  String? _localCoverBase64;
  Timer? _autoSaveTimer;
  DateTime? _lastSaved;

  static const Duration _autoSaveDelay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _diary = widget.diary;
    _titleController = TextEditingController(
      text: _diary.title == 'Dear Diary...' ? '' : _diary.title,
    );
    _contentController = TextEditingController(text: _diary.content);
    _contentFocusNode = FocusNode();

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    // Save before disposing if there are changes
    if (_hasChanges) {
      _saveNow();
    }
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
    // Schedule auto-save
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(_autoSaveDelay, () {
      _autoSave();
    });
  }

  Future<void> _autoSave() async {
    if (!_hasChanges || _isSaving) return;

    setState(() => _isSaving = true);

    final title = _titleController.text.trim().isEmpty
        ? 'Untitled Note'
        : _titleController.text.trim();

    final updatedDiary = _diary.copyWith(
      title: title,
      content: _contentController.text,
      coverUrl: _diary.coverUrl,
      updatedAt: DateTime.now(),
    );

    await _storageService.updateDiary(updatedDiary);

    if (mounted) {
      setState(() {
        _diary = updatedDiary;
        _hasChanges = false;
        _isSaving = false;
        _lastSaved = DateTime.now();
      });
    }
  }

  Future<void> _saveNow() async {
    _autoSaveTimer?.cancel();
    await _autoSave();
  }

  void _insertText(String text) {
    final selection = _contentController.selection;
    final cursorPos = selection.start >= 0
        ? selection.start
        : _contentController.text.length;
    final newText =
        _contentController.text.substring(0, cursorPos) +
        text +
        _contentController.text.substring(cursorPos);
    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(
      offset: cursorPos + text.length,
    );
    _contentFocusNode.requestFocus();
    _onTextChanged();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          await _saveNow();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFC),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: GestureDetector(
                  onTap: () => _contentFocusNode.requestFocus(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCoverSection(),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            height: 1.3,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade300,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _contentFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          DateFormat(
                            'EEEE, MMMM d, yyyy',
                          ).format(_diary.createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(height: 1, color: Colors.grey.shade200),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _contentController,
                          focusNode: _contentFocusNode,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                            height: 1.7,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Write your thoughts...',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade400,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          maxLines: null,
                          minLines: 12,
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () async {
              if (_hasChanges) await _saveNow();
              if (mounted) Navigator.of(context).pop(true);
            },
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: Colors.grey.shade700,
          ),
          // Auto-save status
          _buildSaveStatus(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: Colors.grey.shade700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'delete') _showDeleteConfirmation();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Delete Note',
                          style: TextStyle(color: Colors.red.shade400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveStatus() {
    if (_isSaving) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Saving...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasChanges) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Editing',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
          const SizedBox(width: 6),
          Text(
            _lastSaved != null ? 'Saved ${_formatLastSaved()}' : 'Saved',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastSaved() {
    if (_lastSaved == null) return '';
    final diff = DateTime.now().difference(_lastSaved!);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return DateFormat('HH:mm').format(_lastSaved!);
  }

  Widget _buildCoverSection() {
    final hasCover = _localCoverBase64 != null || _diary.coverUrl != null;

    return GestureDetector(
      onTap: _showCoverOptions,
      child: Container(
        height: hasCover ? 160 : 80,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_localCoverBase64 != null)
                Image.memory(
                  base64Decode(_localCoverBase64!),
                  fit: BoxFit.cover,
                )
              else if (_diary.coverUrl != null)
                Image.network(
                  _diary.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildCoverPlaceholder(),
                )
              else
                _buildCoverPlaceholder(),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasCover
                            ? Icons.edit
                            : Icons.add_photo_alternate_outlined,
                        size: 14,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasCover ? 'Change' : 'Add Cover',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Formatting toolbar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFormatBtn(
                  Icons.format_list_bulleted,
                  'Bullet',
                  () => _insertText('\n• '),
                ),
                _buildFormatBtn(
                  Icons.checklist,
                  'Checklist',
                  () => _insertText('\n☐ '),
                ),
                _buildFormatBtn(
                  Icons.format_list_numbered,
                  'Numbered',
                  _insertNumberedList,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.grey.shade200,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                _buildFormatBtn(
                  Icons.title,
                  'Heading',
                  () => _insertText('\n## '),
                ),
                _buildFormatBtn(
                  Icons.format_quote,
                  'Quote',
                  () => _insertText('\n> '),
                ),
                _buildFormatBtn(
                  Icons.horizontal_rule,
                  'Divider',
                  () => _insertText('\n───────────\n'),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.grey.shade200,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                _buildFormatBtn(
                  Icons.schedule,
                  'Time',
                  () => _insertText(
                    '${DateFormat('HH:mm').format(DateTime.now())} ',
                  ),
                ),
                _buildFormatBtn(Icons.tag, 'Tag', () => _insertText('#')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Action row
          Row(
            children: [
              _buildActionBtn(
                Icons.image_outlined,
                'Photo',
                _requestPhotoPermission,
              ),
              const SizedBox(width: 8),
              _buildActionBtn(
                Icons.auto_awesome,
                'AI Cover',
                _openCoverGenerator,
                isPrimary: true,
              ),
              const Spacer(),
              Text(
                '${_contentController.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length} words',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildActionBtn(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppTheme.primary.withAlpha(20)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? AppTheme.primary : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary ? AppTheme.primary : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _insertNumberedList() {
    final lines = _contentController.text.split('\n');
    int lineNum = 1;
    for (final line in lines) {
      final match = RegExp(r'^(\d+)\. ').firstMatch(line);
      if (match != null) lineNum = int.parse(match.group(1)!) + 1;
    }
    _insertText('\n$lineNum. ');
  }

  // Request photo permission with popup
  Future<void> _requestPhotoPermission() async {
    // First check if permission is already granted
    PermissionStatus currentStatus = await Permission.photos.status;
    if (currentStatus.isDenied || currentStatus.isRestricted) {
      currentStatus = await Permission.storage.status;
    }

    // If already granted, go directly to gallery
    if (currentStatus.isGranted || currentStatus.isLimited) {
      _pickImageFromGallery();
      return;
    }

    // If permanently denied, show settings dialog
    if (currentStatus.isPermanentlyDenied) {
      _showOpenSettingsDialog();
      return;
    }

    // Show explanation dialog before requesting
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.photo_library, color: AppTheme.primary),
            const SizedBox(width: 12),
            const Text('Photo Access'),
          ],
        ),
        content: const Text(
          'We need access to your photos to add cover images to your notes.\n\nYour photos will only be used within this app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Allow Access'),
          ),
        ],
      ),
    );

    if (shouldRequest != true) return;

    // Request the actual permission
    PermissionStatus status = await Permission.photos.request();

    if (status.isDenied) {
      status = await Permission.storage.request();
    }

    if (status.isGranted || status.isLimited) {
      _pickImageFromGallery();
    } else if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog();
    }
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Permission Required'),
        content: const Text(
          'Photo access was denied. Please enable it in your device settings to add cover images.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showCoverOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: Colors.grey.shade700,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _requestPhotoPermission();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.grey.shade700,
                ),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.auto_awesome, color: AppTheme.primary),
                title: const Text('Generate with AI'),
                subtitle: Text(
                  'Free!',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _openCoverGenerator();
                },
              ),
              if (_localCoverBase64 != null || _diary.coverUrl != null)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                  ),
                  title: Text(
                    'Remove Cover',
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeCover();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _localCoverBase64 = base64Encode(bytes);
          _diary = _diary.copyWith(
            coverUrl: 'data:image/jpeg;base64,$_localCoverBase64',
          );
          _hasChanges = true;
        });
        _scheduleAutoSave();
      }
    } catch (e) {
      _showError('Could not access gallery');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _localCoverBase64 = base64Encode(bytes);
          _diary = _diary.copyWith(
            coverUrl: 'data:image/jpeg;base64,$_localCoverBase64',
          );
          _hasChanges = true;
        });
        _scheduleAutoSave();
      }
    } catch (e) {
      _showError('Could not access camera');
    }
  }

  void _removeCover() {
    setState(() {
      _localCoverBase64 = null;
      _diary = Diary(
        id: _diary.id,
        title: _diary.title,
        content: _diary.content,
        coverUrl: null,
        createdAt: _diary.createdAt,
        updatedAt: _diary.updatedAt,
        isFavorite: _diary.isFavorite,
        category: _diary.category,
      );
      _hasChanges = true;
    });
    _scheduleAutoSave();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Note?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.deleteDiary(_diary.id);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  void _openCoverGenerator() async {
    final result = await Navigator.of(
      context,
    ).pushNamed('/cover-generator', arguments: _diary);
    if (result is String && result.isNotEmpty) {
      setState(() {
        _localCoverBase64 = null;
        _diary = _diary.copyWith(coverUrl: result);
        _hasChanges = true;
      });
      _scheduleAutoSave();
    }
  }
}
