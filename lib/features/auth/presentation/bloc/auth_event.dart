import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when app starts to check authentication state
class AuthStarted extends AuthEvent {}

/// Event for user authentication state changes
class AuthUserChanged extends AuthEvent {
  final dynamic user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

/// Event for signing in with email and password
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Event for signing up with email and password
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final UserType userType;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
    required this.userType,
  });

  @override
  List<Object> get props => [email, password, displayName, userType];
}

/// Event for signing out
class AuthSignOutRequested extends AuthEvent {}

/// Event for sending password reset email
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested(this.email);

  @override
  List<Object> get props => [email];
}

/// Event for updating email
class AuthEmailUpdateRequested extends AuthEvent {
  final String newEmail;
  final String currentPassword;

  const AuthEmailUpdateRequested({
    required this.newEmail,
    required this.currentPassword,
  });

  @override
  List<Object> get props => [newEmail, currentPassword];
}

/// Event for updating password
class AuthPasswordUpdateRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthPasswordUpdateRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

/// Event for deleting account
class AuthAccountDeletionRequested extends AuthEvent {
  final String password;

  const AuthAccountDeletionRequested(this.password);

  @override
  List<Object> get props => [password];
}

/// Event for refreshing current user data
class AuthRefreshRequested extends AuthEvent {}