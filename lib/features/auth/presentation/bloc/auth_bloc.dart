import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final AuthRepository _authRepository;
  
  StreamSubscription? _authStateSubscription;

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required AuthRepository authRepository,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthEmailUpdateRequested>(_onEmailUpdateRequested);
    on<AuthPasswordUpdateRequested>(_onPasswordUpdateRequested);
    on<AuthAccountDeletionRequested>(_onAccountDeletionRequested);
  }

  /// Handle app started event
  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    print('🔥 AUTH_BLOC: AuthStarted event received');
    emit(AuthLoading());
    print('🔥 AUTH_BLOC: AuthLoading state emitted');

    try {
      print('🔥 AUTH_BLOC: Setting up auth state listener...');
      // Listen to authentication state changes
      _authStateSubscription?.cancel();
      _authStateSubscription = _authRepository.authStateChanges.listen(
        (user) {
          print('🔥 AUTH_BLOC: Auth state changed, user: ${user?.id}');
          add(AuthUserChanged(user));
        },
      );
      print('🔥 AUTH_BLOC: Auth state listener set up successfully');

      print('🔥 AUTH_BLOC: Checking current user...');
      // Check current user - this should not throw errors, just return null if no user
      final currentUser = await _authRepository.getCurrentUser();
      print('🔥 AUTH_BLOC: Current user check completed: ${currentUser?.id}');
      
      if (currentUser != null) {
        print('🔥 AUTH_BLOC: User found, emitting AuthAuthenticated');
        emit(AuthAuthenticated(currentUser));
      } else {
        print('🔥 AUTH_BLOC: No user found, emitting AuthUnauthenticated');
        emit(AuthUnauthenticated());
      }
      print('🔥 AUTH_BLOC: AuthStarted processing completed successfully');
    } catch (e) {
      print('🔥 AUTH_BLOC: Error in AuthStarted: $e');
      print('🔥 AUTH_BLOC: Error type: ${e.runtimeType}');
      // For startup errors, just emit AuthUnauthenticated instead of AuthError
      print('🔥 AUTH_BLOC: Treating startup error as unauthenticated state');
      emit(AuthUnauthenticated());
    }
  }

  /// Handle user authentication state changes
  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  /// Handle sign in request
  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔥 AUTH_BLOC: Sign in requested');
    print('🔥 AUTH_BLOC: Email: ${event.email}');
    
    emit(AuthLoading());
    print('🔥 AUTH_BLOC: Loading state emitted');

    try {
      print('🔥 AUTH_BLOC: Calling SignInUseCase...');
      final user = await _signInUseCase(
        email: event.email,
        password: event.password,
      );
      print('🔥 AUTH_BLOC: SignInUseCase completed successfully');
      print('🔥 AUTH_BLOC: User signed in: ${user.id} - ${user.displayName}');
      
      emit(AuthAuthenticated(user));
      print('🔥 AUTH_BLOC: AuthAuthenticated state emitted');
    } catch (e) {
      print('🔥 AUTH_BLOC: Error occurred during sign in: $e');
      print('🔥 AUTH_BLOC: Error type: ${e.runtimeType}');
      emit(AuthError(e.toString()));
      print('🔥 AUTH_BLOC: AuthError state emitted');
    }
  }

  /// Handle sign up request
  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔥 AUTH_BLOC: Sign up requested');
    print('🔥 AUTH_BLOC: Email: ${event.email}');
    print('🔥 AUTH_BLOC: Display Name: ${event.displayName}');
    print('🔥 AUTH_BLOC: User Type: ${event.userType}');
    
    emit(AuthLoading());
    print('🔥 AUTH_BLOC: Loading state emitted');

    try {
      print('🔥 AUTH_BLOC: Calling SignUpUseCase...');
      final user = await _signUpUseCase(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        userType: event.userType,
      );
      print('🔥 AUTH_BLOC: SignUpUseCase completed successfully');
      print('🔥 AUTH_BLOC: User created: ${user.id} - ${user.displayName}');
      
      emit(AuthAuthenticated(user));
      print('🔥 AUTH_BLOC: AuthAuthenticated state emitted');
    } catch (e) {
      print('🔥 AUTH_BLOC: Error occurred: $e');
      print('🔥 AUTH_BLOC: Error type: ${e.runtimeType}');
      emit(AuthError(e.toString()));
      print('🔥 AUTH_BLOC: AuthError state emitted');
    }
  }

  /// Handle sign out request
  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _signOutUseCase();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to sign out: ${e.toString()}'));
    }
  }

  /// Handle password reset request
  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(AuthPasswordResetSent(event.email));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Handle email update request
  Future<void> _onEmailUpdateRequested(
    AuthEmailUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Reauthenticate first
      await _authRepository.reauthenticateWithPassword(event.currentPassword);
      
      // Update email
      await _authRepository.updateEmail(event.newEmail);
      
      emit(AuthEmailUpdated(event.newEmail));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Handle password update request
  Future<void> _onPasswordUpdateRequested(
    AuthPasswordUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Reauthenticate first
      await _authRepository.reauthenticateWithPassword(event.currentPassword);
      
      // Update password
      await _authRepository.updatePassword(event.newPassword);
      
      emit(AuthPasswordUpdated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Handle account deletion request
  Future<void> _onAccountDeletionRequested(
    AuthAccountDeletionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Reauthenticate first
      await _authRepository.reauthenticateWithPassword(event.password);
      
      // Delete account
      await _authRepository.deleteAccount();
      
      emit(AuthAccountDeleted());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}