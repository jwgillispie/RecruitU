import '../../../../core/constants/app_constants.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing up with email and password
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String displayName,
    required UserType userType,
  }) async {
    print('🚀 SIGNUP_USECASE: Starting validation');
    print('🚀 SIGNUP_USECASE: Email: $email');
    print('🚀 SIGNUP_USECASE: Display Name: $displayName');
    print('🚀 SIGNUP_USECASE: User Type: $userType');
    
    // Validate email format
    print('🚀 SIGNUP_USECASE: Validating email format...');
    if (!_isValidEmail(email)) {
      print('🚀 SIGNUP_USECASE: Email validation failed');
      throw Exception('Invalid email format');
    }
    print('🚀 SIGNUP_USECASE: Email validation passed');

    // Validate password strength
    print('🚀 SIGNUP_USECASE: Validating password strength...');
    if (!_isStrongPassword(password)) {
      print('🚀 SIGNUP_USECASE: Password validation failed');
      throw Exception('Password must be at least 8 characters with uppercase, lowercase, and number');
    }
    print('🚀 SIGNUP_USECASE: Password validation passed');

    // Validate display name
    print('🚀 SIGNUP_USECASE: Validating display name...');
    if (displayName.trim().isEmpty) {
      print('🚀 SIGNUP_USECASE: Display name is empty');
      throw Exception('Display name cannot be empty');
    }

    if (displayName.trim().length > AppConstants.nameMaxLength) {
      print('🚀 SIGNUP_USECASE: Display name too long: ${displayName.trim().length}');
      throw Exception('Display name cannot exceed ${AppConstants.nameMaxLength} characters');
    }
    print('🚀 SIGNUP_USECASE: Display name validation passed');

    print('🚀 SIGNUP_USECASE: All validations passed, calling repository...');
    final result = await repository.signUpWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
      displayName: displayName.trim(),
      userType: userType,
    );
    print('🚀 SIGNUP_USECASE: Repository call completed successfully');
    print('🚀 SIGNUP_USECASE: User ID: ${result.id}');
    
    return result;
  }

  bool _isValidEmail(String email) {
    return RegExp(AppConstants.emailPattern).hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    return RegExp(AppConstants.passwordPattern).hasMatch(password);
  }
}