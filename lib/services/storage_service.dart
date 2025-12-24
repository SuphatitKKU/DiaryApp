import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/diary.dart';

/// Local storage service for diary data
class StorageService {
  static const String _diariesKey = 'diaries';
  static const Uuid _uuid = Uuid();

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  Future<SharedPreferences> get prefs async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  /// Generate a new unique ID
  static String generateId() => _uuid.v4();

  /// Save all diaries to storage
  Future<void> saveDiaries(List<Diary> diaries) async {
    final p = await prefs;
    final jsonList = diaries.map((d) => d.toJson()).toList();
    await p.setString(_diariesKey, jsonEncode(jsonList));
  }

  /// Load all diaries from storage
  Future<List<Diary>> loadDiaries() async {
    final p = await prefs;
    final jsonString = p.getString(_diariesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Diary.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list if parsing fails
      return [];
    }
  }

  /// Create a new diary
  Future<Diary> createDiary({
    String title = 'Untitled',
    String content = '',
    String? coverUrl,
    String category = 'Personal',
  }) async {
    final diaries = await loadDiaries();
    final now = DateTime.now();

    final diary = Diary(
      id: generateId(),
      title: title,
      content: content,
      coverUrl: coverUrl,
      createdAt: now,
      updatedAt: now,
      category: category,
    );

    diaries.insert(0, diary);
    await saveDiaries(diaries);

    return diary;
  }

  /// Update an existing diary
  Future<void> updateDiary(Diary diary) async {
    final diaries = await loadDiaries();
    final index = diaries.indexWhere((d) => d.id == diary.id);

    if (index != -1) {
      diaries[index] = diary.copyWith(updatedAt: DateTime.now());
      await saveDiaries(diaries);
    }
  }

  /// Delete a diary by ID
  Future<void> deleteDiary(String id) async {
    final diaries = await loadDiaries();
    diaries.removeWhere((d) => d.id == id);
    await saveDiaries(diaries);
  }

  /// Get a single diary by ID
  Future<Diary?> getDiary(String id) async {
    final diaries = await loadDiaries();
    try {
      return diaries.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    final diaries = await loadDiaries();
    final index = diaries.indexWhere((d) => d.id == id);

    if (index != -1) {
      diaries[index] = diaries[index].copyWith(
        isFavorite: !diaries[index].isFavorite,
        updatedAt: DateTime.now(),
      );
      await saveDiaries(diaries);
    }
  }

  /// Get diaries filtered by category
  Future<List<Diary>> getDiariesByCategory(String category) async {
    final diaries = await loadDiaries();

    if (category == 'All') {
      return diaries;
    } else if (category == 'Favorites') {
      return diaries.where((d) => d.isFavorite).toList();
    } else {
      return diaries.where((d) => d.category == category).toList();
    }
  }
}
