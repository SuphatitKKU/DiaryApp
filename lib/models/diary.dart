import 'dart:convert';

class Diary {
  final String id;
  String title;
  String content;
  String? coverUrl;
  DateTime createdAt;
  DateTime updatedAt;
  bool isFavorite;
  String category;

  Diary({
    required this.id,
    required this.title,
    this.content = '',
    this.coverUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.category = 'Personal',
  });

  // Copy with method for immutability
  Diary copyWith({
    String? id,
    String? title,
    String? content,
    String? coverUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    String? category,
  }) {
    return Diary(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      coverUrl: coverUrl ?? this.coverUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
    );
  }

  // Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'coverUrl': coverUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'category': category,
    };
  }

  // Create from JSON map
  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      coverUrl: json['coverUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      category: json['category'] as String? ?? 'Personal',
    );
  }

  // Serialize to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  factory Diary.fromJsonString(String jsonString) {
    return Diary.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  // Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inMinutes < 60) {
      return 'Edited ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Edited ${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Edited yesterday';
    } else if (difference.inDays < 7) {
      return 'Edited ${difference.inDays} days ago';
    } else {
      return 'Edited ${difference.inDays ~/ 7} week${difference.inDays ~/ 7 > 1 ? 's' : ''} ago';
    }
  }
}
