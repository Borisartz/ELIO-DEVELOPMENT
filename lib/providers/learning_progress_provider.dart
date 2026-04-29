import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/learning_progress.dart';
import '../services/progress_service.dart';
import 'auth_provider.dart';

// ---------------------------------------------------------------------------
// Service provider
// ---------------------------------------------------------------------------

final progressServiceProvider = Provider<ProgressService>(
  (_) => ProgressService(),
);

// ---------------------------------------------------------------------------
// Main notifier provider
// ---------------------------------------------------------------------------

final learningProgressProvider =
    AsyncNotifierProvider<LearningProgressNotifier, LearningProgress>(
      LearningProgressNotifier.new,
    );

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class LearningProgressNotifier
    extends AsyncNotifier<LearningProgress> {
  ProgressService get _service => ref.read(progressServiceProvider);

  /// Auto-loads progress for the currently signed-in user.
  /// Re-runs whenever auth state changes.
  @override
  Future<LearningProgress> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return LearningProgress.empty('guest');
    return _service.load(user.uid, isGuest: user.isAnonymous);
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Explicitly (re)load progress for [userId].
  Future<void> loadProgress(String userId) async {
    final isGuest = ref.read(isGuestProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _service.load(userId, isGuest: isGuest),
    );
  }

  /// Call when a user opens a category detail screen.
  Future<void> markLessonViewed(String categoryId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final existing = current.categories[categoryId] ??
        CategoryProgress(categoryId: categoryId);

    if (existing.lessonViewed) return; // already recorded — nothing to do

    final updated = current.copyWith(
      categories: {
        ...current.categories,
        categoryId: existing.copyWith(
          lessonViewed: true,
          lastAccessed: DateTime.now(),
        ),
      },
      lastUpdated: DateTime.now(),
    );

    state = AsyncData(updated);
    await _persist(updated);
  }

  /// Record a completed quiz attempt for [categoryId].
  ///
  /// [score]          — number of correct answers
  /// [totalQuestions] — total questions in the quiz
  Future<void> updateProgress(
    String categoryId,
    int score,
    int totalQuestions,
  ) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final existing = current.categories[categoryId] ??
        CategoryProgress(categoryId: categoryId);

    final newBest =
        score > existing.quizBestScore ? score : existing.quizBestScore;

    final updated = current.copyWith(
      categories: {
        ...current.categories,
        categoryId: existing.copyWith(
          quizBestScore: newBest,
          quizAttempts: existing.quizAttempts + 1,
          totalQuestions: totalQuestions,
          lessonViewed: true, // taking quiz counts as viewing the lesson
          lastAccessed: DateTime.now(),
        ),
      },
      lastUpdated: DateTime.now(),
    );

    state = AsyncData(updated);
    await _persist(updated);
  }

  /// Clear all progress for the current user.
  Future<void> resetProgress() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final isGuest = ref.read(isGuestProvider);
    await _service.clear(user.uid, isGuest: isGuest);
    state = AsyncData(LearningProgress.empty(user.uid));
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _persist(LearningProgress progress) async {
    final isGuest = ref.read(isGuestProvider);
    try {
      await _service.save(progress, isGuest: isGuest);
    } catch (e, st) {
      // Persistence failure is non-fatal: progress is already updated in
      // memory and will be retried on the next mutation.
      assert(() {
        // ignore: avoid_print
        print('[LearningProgressNotifier] persist failed: $e\n$st');
        return true;
      }());
    }
  }
}
