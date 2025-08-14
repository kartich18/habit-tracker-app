import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user.dart' as app_user;
import '../models/habit.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return credential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .update({'lastLogin': FieldValue.serverTimestamp()});

      return credential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get user profile from Firestore
  Future<app_user.User?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return app_user.User(
          name: data['name'] ?? '',
          age: data['age'] ?? 0,
          gender: data['gender'] ?? '',
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, app_user.User user) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'name': user.name,
        'age': user.age,
        'gender': user.gender,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Save habits to Firestore
  Future<void> saveHabits(String userId, List<Habit> habits) async {
    try {
      final batch = _firestore.batch();
      
      // Clear existing habits
      final existingHabits = await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .get();
      
      for (var doc in existingHabits.docs) {
        batch.delete(doc.reference);
      }

      // Add new habits
      for (var habit in habits) {
        final habitRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habit.id);
        batch.set(habitRef, habit.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to save habits: $e');
    }
  }

  // Load habits from Firestore
  Future<List<Habit>> loadHabits(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .get();

      return snapshot.docs
          .map((doc) => Habit.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to load habits: $e');
    }
  }

  // Add a single habit
  Future<void> addHabit(String userId, Habit habit) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habit.id)
          .set(habit.toJson());
    } catch (e) {
      throw Exception('Failed to add habit: $e');
    }
  }

  // Update a habit
  Future<void> updateHabit(String userId, Habit habit) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habit.id)
          .update(habit.toJson());
    } catch (e) {
      throw Exception('Failed to update habit: $e');
    }
  }

  // Delete a habit
  Future<void> deleteHabit(String userId, String habitId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habitId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete habit: $e');
    }
  }

  // Backup data to Firebase Storage
  Future<String> backupData(String userId, String data) async {
    try {
      final ref = _storage
          .ref()
          .child('backups')
          .child(userId)
          .child('${DateTime.now().millisecondsSinceEpoch}.json');
      
      await ref.putString(data);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to backup data: $e');
    }
  }

  // Restore data from Firebase Storage
  Future<String> restoreData(String backupUrl) async {
    try {
      final ref = _storage.refFromURL(backupUrl);
      return await ref.getData().then((data) => String.fromCharCodes(data!));
    } catch (e) {
      throw Exception('Failed to restore data: $e');
    }
  }

  // Handle Firebase Auth errors
  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return 'Authentication failed: ${e.message}';
      }
    }
    return 'An unexpected error occurred: $e';
  }
}
