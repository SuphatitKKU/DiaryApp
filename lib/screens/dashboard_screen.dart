import 'package:flutter/material.dart';
import '../models/diary.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/diary_card.dart';
import '../widgets/glass_container.dart';

/// Dashboard screen with diary grid
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StorageService _storageService = StorageService();
  List<Diary> _diaries = [];
  String _selectedCategory = 'All';
  int _currentNavIndex = 0;
  bool _isLoading = true;

  final List<String> _categories = ['All', 'Favorites', 'Personal', 'Work'];

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    setState(() => _isLoading = true);
    final diaries = await _storageService.getDiariesByCategory(
      _selectedCategory,
    );
    setState(() {
      _diaries = diaries;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        showBlobs: true,
        child: Stack(
          children: [
            // Main content
            CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: GlassHeader(
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Diaries',
                                  style: AppTheme.headlineLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Good ${_getGreeting()}, Writer',
                                  style: AppTheme.labelSmall,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildIconButton(Icons.search),
                                const SizedBox(width: 12),
                                _buildAvatar(),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Category tabs
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((category) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _buildCategoryChip(category),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECENT COLLECTIONS',
                          style: AppTheme.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All',
                            style: AppTheme.labelSmall.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Grid
                _isLoading
                    ? const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 160),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 24,
                                childAspectRatio: 0.6,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            if (index == _diaries.length) {
                              return NewDiaryCard(onTap: _createNewDiary);
                            }
                            final diary = _diaries[index];
                            return DiaryCard(
                              diary: diary,
                              onTap: () => _openEditor(diary),
                              onFavoriteToggle: () => _toggleFavorite(diary.id),
                            );
                          }, childCount: _diaries.length + 1),
                        ),
                      ),
              ],
            ),
            // FAB
            Positioned(
              bottom: 100,
              right: 24,
              child: FloatingActionButton(
                onPressed: _createNewDiary,
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 8,
                child: const Icon(Icons.edit_square, size: 28),
              ),
            ),
            // Bottom nav
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(
                currentIndex: _currentNavIndex,
                onTap: (index) {
                  setState(() => _currentNavIndex = index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Icon(icon, size: 20, color: AppTheme.textSecondary),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipOval(
        child: Image.network(
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBXJZguCAnKwc3TnZTfhORMiLwN3bMrQo4nNdQ-D1yYS-97QBHPR6WOXJlOCZJVVjabxXsj3raUUeNJEitkmZ6sVUVWV5zoFx2keqaFwt0McGUHrDN6qcgoN-CCnB4dTCHoAt_Ps-daYGXN347NXAKuBbcRwWDjSB86urhjEUutI2CNQJXTOr99YLm3nwGdardW8YpuG52vX_pQfLjMhnHWLkgi8HVO3aMcGjvfXM6Gp0XJ6V3ghyzZWlFcnmcw7XxEzb-RElKrRFeP',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppTheme.primaryLight,
              child: const Icon(Icons.person, color: AppTheme.primary),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = category);
        _loadDiaries();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade100),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Text(
          category,
          style: AppTheme.labelLarge.copyWith(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  Future<void> _createNewDiary() async {
    final diary = await _storageService.createDiary(title: 'Dear Diary...');
    if (mounted) {
      _openEditor(diary);
    }
  }

  Future<void> _openEditor(Diary diary) async {
    final result = await Navigator.of(
      context,
    ).pushNamed('/editor', arguments: diary);
    // Reload diaries when returning from editor to get updated covers
    if (result == true) {
      _loadDiaries();
    }
  }

  Future<void> _toggleFavorite(String id) async {
    await _storageService.toggleFavorite(id);
    _loadDiaries();
  }
}
