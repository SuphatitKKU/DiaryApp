import 'package:flutter/material.dart';
import '../models/diary.dart';
import '../services/pollinations_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

/// Cover generator screen using Pollinations.AI
class CoverGeneratorScreen extends StatefulWidget {
  final Diary diary;

  const CoverGeneratorScreen({super.key, required this.diary});

  @override
  State<CoverGeneratorScreen> createState() => _CoverGeneratorScreenState();
}

class _CoverGeneratorScreenState extends State<CoverGeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();
  String _selectedStyle = 'Watercolor';
  String? _generatedImageUrl;
  bool _isGenerating = false;
  bool _imageLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with diary title if available
    if (widget.diary.title.isNotEmpty) {
      _promptController.text = widget.diary.title;
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Free badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Free! No API Key Required',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Preview
                    _buildPreviewSection(),
                    const SizedBox(height: 32),

                    // Prompt input
                    Text('Describe your cover', style: AppTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _promptController,
                      style: AppTheme.bodyLarge,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'e.g., sunset over mountains, blue ocean waves...',
                        hintStyle: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textMuted,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Style presets
                    Text('Art Style', style: AppTheme.titleMedium),
                    const SizedBox(height: 12),
                    _buildStyleSelector(),
                    const SizedBox(height: 32),

                    // Generate button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            (_isGenerating ||
                                (_generatedImageUrl != null &&
                                    !_imageLoaded &&
                                    !_hasError))
                            ? null
                            : _generateCover,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          disabledBackgroundColor: AppTheme.primary.withAlpha(
                            128,
                          ),
                        ),
                        child:
                            (_isGenerating ||
                                (_generatedImageUrl != null &&
                                    !_imageLoaded &&
                                    !_hasError))
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Generating...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Generate Cover',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    // Sample prompts
                    const SizedBox(height: 24),
                    Text('Ideas', style: AppTheme.labelLarge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSuggestionChip('Ocean at sunrise'),
                        _buildSuggestionChip('Autumn forest'),
                        _buildSuggestionChip('Purple sky'),
                        _buildSuggestionChip('Cherry blossoms'),
                        _buildSuggestionChip('City at night'),
                        _buildSuggestionChip('Mountain lake'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () => _promptController.text = text,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: AppTheme.bodyMedium),
      ),
    );
  }

  Widget _buildHeader() {
    return GlassHeader(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            color: AppTheme.textSecondary,
          ),
          Text('AI Cover Generator', style: AppTheme.titleLarge),
          TextButton(
            onPressed:
                (_generatedImageUrl != null && _imageLoaded && !_hasError)
                ? _applyCover
                : null,
            child: Text(
              'Apply',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    (_generatedImageUrl != null && _imageLoaded && !_hasError)
                    ? AppTheme.primary
                    : AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    // Show loading when generating or when URL set but image not loaded yet
    final showLoading =
        _isGenerating ||
        (_generatedImageUrl != null && !_imageLoaded && !_hasError);

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppTheme.surfaceLight,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 20),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background content
            if (showLoading)
              _buildLoadingState()
            else if (_hasError)
              _buildErrorState()
            else if (_generatedImageUrl != null && _imageLoaded)
              Image.network(_generatedImageUrl!, fit: BoxFit.cover)
            else
              _buildEmptyState(),

            // Hidden image loader (preloads the image)
            if (_generatedImageUrl != null && !_imageLoaded && !_hasError)
              Opacity(
                opacity: 0,
                child: Image.network(
                  _generatedImageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    // Image is still loading
                    return const SizedBox();
                  },
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                        if (frame != null) {
                          // Image loaded successfully
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && !_imageLoaded) {
                              setState(() => _imageLoaded = true);
                            }
                          });
                        }
                        return child;
                      },
                  errorBuilder: (context, error, stackTrace) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && !_hasError) {
                        setState(() => _hasError = true);
                      }
                    });
                    return const SizedBox();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withAlpha(13),
            AppTheme.auroraFuchsia.withAlpha(13),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: AppTheme.textMuted.withAlpha(128),
          ),
          const SizedBox(height: 12),
          Text(
            'Your cover will appear here',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withAlpha(26),
            AppTheme.auroraFuchsia.withAlpha(26),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Creating your cover...',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text('This may take 10-30 seconds', style: AppTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.red.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(
            'Failed to load image',
            style: AppTheme.bodyMedium.copyWith(color: Colors.red.shade400),
          ),
          const SizedBox(height: 4),
          Text(
            'Check your internet connection',
            style: AppTheme.labelSmall.copyWith(color: Colors.red.shade300),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _generateCover,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: PollinationsService.stylePresets.map((style) {
        final isSelected = _selectedStyle == style;
        return GestureDetector(
          onTap: () => setState(() => _selectedStyle = style),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primary : Colors.grey.shade200,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withAlpha(77),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              style,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _generateCover() {
    if (_promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a description for your cover'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedImageUrl = null;
      _imageLoaded = false;
      _hasError = false;
    });

    // Generate URL with unique timestamp to avoid caching
    final url = PollinationsService.generateCoverUrl(
      theme: _promptController.text,
      style: _selectedStyle,
      width: 800,
      height: 600,
    );

    // Add cache buster
    final urlWithCacheBuster =
        '$url&t=${DateTime.now().millisecondsSinceEpoch}';

    // Short delay then set URL - loading will continue until image is loaded
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _generatedImageUrl = urlWithCacheBuster;
          _isGenerating = false;
          // Keep _imageLoaded = false until frameBuilder confirms load
        });
      }
    });
  }

  void _applyCover() {
    if (_generatedImageUrl != null && _imageLoaded && !_hasError) {
      Navigator.of(context).pop(_generatedImageUrl);
    }
  }
}
