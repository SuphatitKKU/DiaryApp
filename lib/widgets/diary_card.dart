import 'package:flutter/material.dart';
import '../models/diary.dart';
import '../theme/app_theme.dart';

/// Diary card widget styled like a book with spine
class DiaryCard extends StatelessWidget {
  final Diary diary;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const DiaryCard({
    super.key,
    required this.diary,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover with spine
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      // Cover image or placeholder
                      Positioned.fill(
                        child: diary.coverUrl != null
                            ? Image.network(
                                diary.coverUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholderCover();
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return _buildLoadingCover(
                                        loadingProgress,
                                      );
                                    },
                              )
                            : _buildPlaceholderCover(),
                      ),
                      // Dark overlay
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      // Spine effect
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 6,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            border: Border(
                              right: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Favorite/Lock icon
                      Positioned(top: 8, right: 8, child: _buildStatusIcon()),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Title
          Text(
            diary.title,
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Last edited
          Text(diary.formattedDate, style: AppTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (diary.isFavorite) {
      return GestureDetector(
        onTap: onFavoriteToggle,
        child: const Icon(
          Icons.favorite,
          color: Colors.white,
          size: 20,
          shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPlaceholderCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.3),
            AppTheme.auroraFuchsia.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_stories,
          size: 48,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildLoadingCover(ImageChunkEvent loadingProgress) {
    return Container(
      color: AppTheme.surfaceLight,
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
              : null,
          strokeWidth: 2,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}

/// New diary card with add button
class NewDiaryCard extends StatelessWidget {
  final VoidCallback? onTap;

  const NewDiaryCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.textMuted.withValues(alpha: 0.5),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'New Diary',
                      style: AppTheme.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
