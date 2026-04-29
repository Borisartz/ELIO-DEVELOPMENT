import 'dart:convert';

/// Progress for a single waste category.
class CategoryProgress {
  final String categoryId;

  /// Whether the user has opened the lesson detail screen.
  final bool lessonViewed;

  /// Best quiz score achieved across all attempts.
  final int quizBestScore;

  /// Total number of quiz attempts.
  final int quizAttempts;

  /// Total number of questions in the quiz (set on first attempt).
  final int totalQuestions;

  /// When the category was last interacted with.
  final DateTime? lastAccessed;

  const CategoryProgress({
    required this.categoryId,
    this.lessonViewed = false,
    this.quizBestScore = 0,
    this.quizAttempts = 0,
    this.totalQuestions = 0,
    this.lastAccessed,
  });

  static const double _lessonViewWeight = 0.4;
  static const double _quizScoreWeight = 0.6;

  /// 0.0 – 1.0 composite score:
  ///   [_lessonViewWeight] for viewing the lesson,
  ///   [_quizScoreWeight] × (bestScore / totalQuestions) for the quiz.
  double get progressPercentage {
    if (totalQuestions == 0) return lessonViewed ? _lessonViewWeight : 0.0;
    final quizFraction = quizBestScore / totalQuestions;
    final lessonFraction = lessonViewed ? _lessonViewWeight : 0.0;
    return (lessonFraction + quizFraction * _quizScoreWeight).clamp(0.0, 1.0);
  }

  CategoryProgress copyWith({
    bool? lessonViewed,
    int? quizBestScore,
    int? quizAttempts,
    int? totalQuestions,
    DateTime? lastAccessed,
  }) {
    return CategoryProgress(
      categoryId: categoryId,
      lessonViewed: lessonViewed ?? this.lessonViewed,
      quizBestScore: quizBestScore ?? this.quizBestScore,
      quizAttempts: quizAttempts ?? this.quizAttempts,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  Map<String, dynamic> toMap() => {
    'categoryId': categoryId,
    'lessonViewed': lessonViewed,
    'quizBestScore': quizBestScore,
    'quizAttempts': quizAttempts,
    'totalQuestions': totalQuestions,
    'lastAccessed': lastAccessed?.toIso8601String(),
  };

  factory CategoryProgress.fromMap(Map<String, dynamic> map) =>
      CategoryProgress(
        categoryId: (map['categoryId'] as String?) ?? '',
        lessonViewed: (map['lessonViewed'] as bool?) ?? false,
        quizBestScore: (map['quizBestScore'] as int?) ?? 0,
        quizAttempts: (map['quizAttempts'] as int?) ?? 0,
        totalQuestions: (map['totalQuestions'] as int?) ?? 0,
        lastAccessed: map['lastAccessed'] != null
            ? DateTime.tryParse(map['lastAccessed'] as String)
            : null,
      );
}

/// Aggregated learning progress for one user.
class LearningProgress {
  final String userId;

  /// Keyed by [WasteCategory.id].
  final Map<String, CategoryProgress> categories;

  final DateTime? lastUpdated;

  const LearningProgress({
    required this.userId,
    this.categories = const {},
    this.lastUpdated,
  });

  /// Average progress across all tracked categories (0.0 – 1.0).
  double get overallProgress {
    if (categories.isEmpty) return 0.0;
    final total = categories.values
        .fold<double>(0.0, (sum, c) => sum + c.progressPercentage);
    return total / categories.length;
  }

  LearningProgress copyWith({
    Map<String, CategoryProgress>? categories,
    DateTime? lastUpdated,
  }) {
    return LearningProgress(
      userId: userId,
      categories: categories ?? this.categories,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'categories': {
      for (final e in categories.entries) e.key: e.value.toMap(),
    },
    'lastUpdated': lastUpdated?.toIso8601String(),
  };

  factory LearningProgress.fromMap(Map<String, dynamic> map) {
    final rawCats = map['categories'];
    final cats = <String, CategoryProgress>{};
    if (rawCats is Map) {
      for (final entry in rawCats.entries) {
        if (entry.value is Map<String, dynamic>) {
          cats[entry.key as String] =
              CategoryProgress.fromMap(entry.value as Map<String, dynamic>);
        }
      }
    }
    return LearningProgress(
      userId: (map['userId'] as String?) ?? '',
      categories: cats,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.tryParse(map['lastUpdated'] as String)
          : null,
    );
  }

  /// Convenience: empty progress for [userId].
  factory LearningProgress.empty(String userId) =>
      LearningProgress(userId: userId);

  // JSON helpers used by SharedPreferences persistence.
  String toJson() => jsonEncode(toMap());

  factory LearningProgress.fromJson(String source) =>
      LearningProgress.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
