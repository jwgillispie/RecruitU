import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

/// Implementation of AuthRepository using Firebase
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await _dataSource.getCurrentUser();
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _dataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required UserType userType,
  }) async {
    print('📊 AUTH_REPOSITORY: Received signup request');
    print('📊 AUTH_REPOSITORY: Email: $email');
    print('📊 AUTH_REPOSITORY: Display Name: $displayName');
    print('📊 AUTH_REPOSITORY: User Type: $userType');
    
    try {
      print('📊 AUTH_REPOSITORY: Calling Firebase data source...');
      final result = await _dataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        userType: userType,
      );
      print('📊 AUTH_REPOSITORY: Data source call completed');
      print('📊 AUTH_REPOSITORY: Result: ${result.id} - ${result.displayName}');
      return result;
    } catch (e) {
      print('📊 AUTH_REPOSITORY: Error in data source: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _dataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<bool> isSignedIn() async {
    return _dataSource.isSignedIn();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _dataSource.authStateChanges;
  }

  @override
  Future<void> deleteAccount() async {
    await _dataSource.deleteAccount();
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    await _dataSource.updateEmail(newEmail);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _dataSource.updatePassword(newPassword);
  }

  @override
  Future<void> reauthenticateWithPassword(String password) async {
    await _dataSource.reauthenticateWithPassword(password);
  }
}