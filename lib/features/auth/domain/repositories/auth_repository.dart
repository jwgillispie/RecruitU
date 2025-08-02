import '../../../../core/constants/app_constants.dart';
import '../entities/user_entity.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Get current authenticated user
  Future<UserEntity?> getCurrentUser();
  
  /// Sign in with email and password
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  /// Sign up with email and password
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required UserType userType,
  });
  
  /// Sign out current user
  Future<void> signOut();
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);
  
  /// Check if user is signed in
  Future<bool> isSignedIn();
  
  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;
  
  /// Delete user account
  Future<void> deleteAccount();
  
  /// Update user email
  Future<void> updateEmail(String newEmail);
  
  /// Update user password
  Future<void> updatePassword(String newPassword);
  
  /// Reauthenticate user with password
  Future<void> reauthenticateWithPassword(String password);
  
  /// Update user profile completion status
  Future<void> updateProfileCompletionStatus(String userId, bool isComplete);
}