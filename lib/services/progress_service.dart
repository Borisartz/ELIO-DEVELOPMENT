import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_progress.dart';

/// Handles persistence of [LearningProgress]:
///   • Firestore for authenticated users
///   • SharedPreferences for anonymous/guest users
class ProgressService {
  static const _prefKey = 'elio_learning_progress';
  static const _usersCollection = 'users';
  static const _progressSubcollection = 'progress';
  static const _learningDocId = 'learning';

  final FirebaseFirestore _firestore;

  ProgressService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Firestore
  // ---------------------------------------------------------------------------

  Future<LearningProgress> loadFromFirestore(String userId) async {
    final doc = await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_progressSubcollection)
        .doc(_learningDocId)
        .get();

    if (!doc.exists || doc.data() == null) {
      return LearningProgress.empty(userId);
    }
    return LearningProgress.fromMap(doc.data()!);
  }

  Future<void> saveToFirestore(LearningProgress progress) async {
    await _firestore
        .collection(_usersCollection)
        .doc(progress.userId)
        .collection(_progressSubcollection)
        .doc(_learningDocId)
        .set(progress.toMap());
  }

  Future<void> clearFromFirestore(String userId) async {
    await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_progressSubcollection)
        .doc(_learningDocId)
        .delete();
  }

  // ---------------------------------------------------------------------------
  // SharedPreferences (guest / offline)
  // ---------------------------------------------------------------------------

  Future<LearningProgress> loadFromLocal(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw == null) return LearningProgress.empty(userId);
    try {
      return LearningProgress.fromJson(raw);
    } catch (_) {
      return LearningProgress.empty(userId);
    }
  }

  Future<void> saveToLocal(LearningProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, progress.toJson());
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  // ---------------------------------------------------------------------------
  // Unified API — caller picks backend via [isGuest]
  // ---------------------------------------------------------------------------

  Future<LearningProgress> load(
    String userId, {
    required bool isGuest,
  }) {
    return isGuest ? loadFromLocal(userId) : loadFromFirestore(userId);
  }

  Future<void> save(
    LearningProgress progress, {
    required bool isGuest,
  }) {
    return isGuest ? saveToLocal(progress) : saveToFirestore(progress);
  }

  Future<void> clear(String userId, {required bool isGuest}) {
    return isGuest ? clearLocal() : clearFromFirestore(userId);
  }
}
