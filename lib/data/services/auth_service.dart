import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_role.dart';
import '../models/app_user.dart';

/// A user-friendly error that the UI can show as is.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
}

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageFor(e.code));
    } catch (_) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  /// Creates the account, then a profile document in users/{uid}.
  /// New accounts are ALWAYS students. Admins are promoted by hand in the
  /// Firebase console, and the Firestore rules enforce this.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      await user.updateDisplayName(name.trim());
      await _db.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageFor(e.code));
    } catch (_) {
      throw const AuthFailure(
        "Your account was created but we couldn't finish setting it up. "
        'Please sign in again.',
      );
    }
  }

  /// Live profile of the signed-in user. Because it is a stream, an admin
  /// promotion made in the console applies without signing in again, and a
  /// profile written just after registration shows up by itself.
  Stream<AppUser> watchUser(User user) {
    AppUser build(Map<String, dynamic>? data) {
      final email = user.email ?? '';
      var name = (data?['name'] as String?) ?? user.displayName ?? '';
      if (name.trim().isEmpty) name = email.split('@').first;
      return AppUser(
        uid: user.uid,
        name: name,
        email: email,
        role: AppRole.fromString(data?['role'] as String?),
      );
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => build(doc.data()))
        .transform(
          StreamTransformer<AppUser, AppUser>.fromHandlers(
            handleError: (error, stackTrace, sink) => sink.add(build(null)),
          ),
        );
  }

  Future<void> signOut() => _auth.signOut();

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'No connection. Check your internet and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
