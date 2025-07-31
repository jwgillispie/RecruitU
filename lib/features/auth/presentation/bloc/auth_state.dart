import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when app starts
class AuthInitial extends AuthState {}

/// Loading state during authentication operations
class AuthLoading extends AuthState {}

/// Authenticated state with user data
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {}

/// Error state with error message
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

/// Success state for operations like password reset
class AuthSuccess extends AuthState {
  final String message;

  const AuthSuccess(this.message);

  @override
  List<Object> get props => [message];
}

/// State when password reset email has been sent
class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent(this.email);

  @override
  List<Object> get props => [email];
}

/// State when email has been updated
class AuthEmailUpdated extends AuthState {
  final String newEmail;

  const AuthEmailUpdated(this.newEmail);

  @override
  List<Object> get props => [newEmail];
}

/// State when password has been updated
class AuthPasswordUpdated extends AuthState {}

/// State when account has been deleted
class AuthAccountDeleted extends AuthState {}