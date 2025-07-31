import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Firebase Auth data source
class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource(this._firebaseAuth, this._firestore);

  /// Get current Firebase user
  User? getCurrentFirebaseUser() {
    return _firebaseAuth.currentUser;
  }

  /// Get current user from Firestore
  Future<UserModel?> getCurrentUser() async {
    print('🔥 FIREBASE_DATASOURCE: Getting current user...');
    final firebaseUser = getCurrentFirebaseUser();
    print('🔥 FIREBASE_DATASOURCE: Firebase user: ${firebaseUser?.uid}');
    if (firebaseUser == null) {
      print('🔥 FIREBASE_DATASOURCE: No Firebase user found');
      return null;
    }

    try {
      print('🔥 FIREBASE_DATASOURCE: Fetching user document from Firestore...');
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      print('🔥 FIREBASE_DATASOURCE: Document exists: ${doc.exists}');
      if (doc.exists) {
        final userModel = UserModel.fromFirestore(doc);
        print('🔥 FIREBASE_DATASOURCE: User model created: ${userModel.id}');
        return userModel;
      }
      print('🔥 FIREBASE_DATASOURCE: User document does not exist');
      return null;
    } catch (e) {
      print('🔥 FIREBASE_DATASOURCE: Error getting current user: $e');
      throw Exception('Failed to get current user: $e');
    }
  }

  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      // Update last active time
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .update({
        'lastActiveAt': FieldValue.serverTimestamp(),
      });

      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign up with email and password
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required UserType userType,
  }) async {
    print('🔥 FIREBASE_DATASOURCE: Starting signup process');
    print('🔥 FIREBASE_DATASOURCE: Email: $email');
    print('🔥 FIREBASE_DATASOURCE: Display Name: $displayName');
    print('🔥 FIREBASE_DATASOURCE: User Type: $userType');
    
    try {
      print('🔥 FIREBASE_DATASOURCE: Creating Firebase Auth user...');
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('🔥 FIREBASE_DATASOURCE: Firebase Auth user created successfully');
      print('🔥 FIREBASE_DATASOURCE: User UID: ${credential.user?.uid}');

      if (credential.user == null) {
        print('🔥 FIREBASE_DATASOURCE: ERROR - No user returned from Firebase Auth');
        throw Exception('Sign up failed: No user returned');
      }

      print('🔥 FIREBASE_DATASOURCE: Updating display name...');
      // Update Firebase user display name
      await credential.user!.updateDisplayName(displayName);
      print('🔥 FIREBASE_DATASOURCE: Display name updated successfully');

      // Create user document in Firestore
      print('🔥 FIREBASE_DATASOURCE: Creating Firestore document...');
      final now = DateTime.now();
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        userType: userType,
        createdAt: now,
        lastActiveAt: now,
        isVerified: credential.user!.emailVerified,
      );
      
      print('🔥 FIREBASE_DATASOURCE: UserModel created: ${userModel.toJson()}');
      print('🔥 FIREBASE_DATASOURCE: Firestore collection: ${AppConstants.usersCollection}');
      print('🔥 FIREBASE_DATASOURCE: Document ID: ${credential.user!.uid}');

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());
      
      print('🔥 FIREBASE_DATASOURCE: Firestore document created successfully');
      print('🔥 FIREBASE_DATASOURCE: Signup process completed successfully');

      return userModel;
    } on FirebaseAuthException catch (e) {
      print('🔥 FIREBASE_DATASOURCE: FirebaseAuthException: ${e.code} - ${e.message}');
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      print('🔥 FIREBASE_DATASOURCE: General exception: $e');
      print('🔥 FIREBASE_DATASOURCE: Exception type: ${e.runtimeType}');
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Check if user is signed in
  bool isSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final doc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get();

        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
        return null;
      } catch (e) {
        return null;
      }
    });
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    final user = getCurrentFirebaseUser();
    if (user == null) throw Exception('No user to delete');

    try {
      // Delete user document from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();

      // Delete Firebase Auth user
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    final user = getCurrentFirebaseUser();
    if (user == null) throw Exception('No authenticated user');

    try {
      await user.updateEmail(newEmail);
      
      // Update email in Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({'email': newEmail});
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    final user = getCurrentFirebaseUser();
    if (user == null) throw Exception('No authenticated user');

    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  /// Reauthenticate user with password
  Future<void> reauthenticateWithPassword(String password) async {
    final user = getCurrentFirebaseUser();
    if (user == null || user.email == null) {
      throw Exception('No authenticated user');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Failed to reauthenticate: $e');
    }
  }

  /// Map FirebaseAuthException to readable error messages
  Exception _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No account found with this email address.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'email-already-in-use':
        return Exception('An account with this email already exists.');
      case 'weak-password':
        return Exception('Password is too weak. Please choose a stronger password.');
      case 'invalid-email':
        return Exception('Please enter a valid email address.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please try again later.');
      case 'operation-not-allowed':
        return Exception('Email/password accounts are not enabled.');
      case 'requires-recent-login':
        return Exception('Please sign in again to continue.');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }
}