import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider)?.isAnonymous ?? true;
});

extension AuthEmailOrUsernameSignIn on FirebaseAuth {
  Future<UserCredential> signInWithEmailOrUsername(
    String input,
    String password,
  ) async {
    final normalizedInput = input.trim();

    if (normalizedInput.contains('@')) {
      return signInWithEmailAndPassword(
        email: normalizedInput,
        password: password,
      );
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: normalizedInput)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No account found for that username.',
        );
      }

      final data = snapshot.docs.first.data();
      final email = data['email'];

      if (email is! String || email.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No account found for that username.',
        );
      }

      return signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (_) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No account found for that username.',
      );
    }
  }
}
