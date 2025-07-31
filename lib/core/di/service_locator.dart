import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Auth imports
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

// Profile imports
import '../../features/profile/data/datasources/firebase_profile_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/data/services/photo_upload_service.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/create_profile_from_form_usecase.dart';
import '../../features/profile/domain/usecases/get_profiles_for_discovery_usecase.dart';

// Matching imports
import '../../features/matching/data/datasources/firebase_matching_datasource.dart';
import '../../features/matching/data/repositories/matching_repository_impl.dart';
import '../../features/matching/domain/repositories/matching_repository.dart';
import '../../features/matching/domain/usecases/swipe_user_usecase.dart';
import '../../features/matching/domain/usecases/get_matches_usecase.dart';
import '../../features/matching/domain/usecases/unmatch_usecase.dart';
import '../../features/matching/presentation/bloc/matching_bloc.dart';

// Chat imports
import '../../features/chat/data/datasources/firebase_chat_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/create_chat_usecase.dart';
import '../../features/chat/domain/usecases/get_user_chats_usecase.dart';
import '../../features/chat/domain/usecases/get_chat_messages_usecase.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/domain/usecases/mark_messages_read_usecase.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

/// Service Locator for Dependency Injection
/// 
/// This class sets up all the dependencies for the application using GetIt.
/// It follows the dependency injection pattern to ensure testability and
/// maintainability of the codebase.
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  
  static GetIt get instance => _getIt;
  
  /// Initialize all dependencies
  static Future<void> init() async {
    print('🔧 SERVICE_LOCATOR: Starting dependency registration...');
    
    // External dependencies
    print('🔧 SERVICE_LOCATOR: Registering external dependencies...');
    await _registerExternalDependencies();
    print('🔧 SERVICE_LOCATOR: External dependencies registered');
    
    // Core dependencies
    print('🔧 SERVICE_LOCATOR: Registering core dependencies...');
    await _registerCoreDependencies();
    print('🔧 SERVICE_LOCATOR: Core dependencies registered');
    
    // Data sources
    print('🔧 SERVICE_LOCATOR: Registering data sources...');
    await _registerDataSources();
    print('🔧 SERVICE_LOCATOR: Data sources registered');
    
    // Repositories
    print('🔧 SERVICE_LOCATOR: Registering repositories...');
    await _registerRepositories();
    print('🔧 SERVICE_LOCATOR: Repositories registered');
    
    // Use cases
    print('🔧 SERVICE_LOCATOR: Registering use cases...');
    await _registerUseCases();
    print('🔧 SERVICE_LOCATOR: Use cases registered');
    
    // BLoCs
    print('🔧 SERVICE_LOCATOR: Registering BLoCs...');
    await _registerBlocs();
    print('🔧 SERVICE_LOCATOR: BLoCs registered');
    
    print('🔧 SERVICE_LOCATOR: All dependencies registered successfully');
  }
  
  /// Register external dependencies like Firebase, SharedPreferences
  static Future<void> _registerExternalDependencies() async {
    // Firebase instances
    _getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    _getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
    _getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
    
    // Shared Preferences
    final sharedPreferences = await SharedPreferences.getInstance();
    _getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  }
  
  /// Register core dependencies like network clients, services
  static Future<void> _registerCoreDependencies() async {
    // TODO: Register Dio HTTP client, cache managers, etc.
  }
  
  /// Register data sources
  static Future<void> _registerDataSources() async {
    // Auth data sources
    _getIt.registerLazySingleton<FirebaseAuthDataSource>(
      () => FirebaseAuthDataSource(_getIt(), _getIt()),
    );
    
    // Profile data sources
    _getIt.registerLazySingleton<FirebaseProfileDataSource>(
      () => FirebaseProfileDataSource(_getIt(), _getIt()),
    );
    
    // Matching data sources
    _getIt.registerLazySingleton<FirebaseMatchingDatasource>(
      () => FirebaseMatchingDatasource(_getIt()),
    );
    
    // Chat data sources
    _getIt.registerLazySingleton<FirebaseChatDataSource>(
      () => FirebaseChatDataSource(),
    );
  }
  
  /// Register repository implementations
  static Future<void> _registerRepositories() async {
    // Auth repository
    _getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(_getIt()),
    );
    
    // Profile services
    _getIt.registerLazySingleton<PhotoUploadService>(
      () => PhotoUploadService(),
    );
    
    // Profile repository
    _getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(_getIt()),
    );
    
    // Matching repository
    _getIt.registerLazySingleton<MatchingRepository>(
      () => MatchingRepositoryImpl(_getIt(), _getIt()),
    );
    
    // Chat repository
    _getIt.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(dataSource: _getIt()),
    );
  }
  
  /// Register use cases
  static Future<void> _registerUseCases() async {
    // Auth use cases
    _getIt.registerLazySingleton(() => SignInUseCase(_getIt()));
    _getIt.registerLazySingleton(() => SignUpUseCase(_getIt()));
    _getIt.registerLazySingleton(() => SignOutUseCase(_getIt()));
    
    // Profile use cases
    _getIt.registerLazySingleton(() => GetProfileUseCase(_getIt()));
    _getIt.registerLazySingleton(() => UpdateProfileUseCase(_getIt()));
    _getIt.registerLazySingleton(() => CreateProfileFromFormUseCase(_getIt()));
    _getIt.registerLazySingleton(() => GetProfilesForDiscoveryUseCase(_getIt()));
    
    // Matching use cases
    _getIt.registerLazySingleton(() => SwipeUserUseCase(_getIt()));
    _getIt.registerLazySingleton(() => GetMatchesUseCase(_getIt()));
    _getIt.registerLazySingleton(() => WatchMatchesUseCase(_getIt()));
    _getIt.registerLazySingleton(() => UnmatchUseCase(_getIt()));
    
    // Chat use cases
    _getIt.registerLazySingleton(() => CreateChatUseCase(_getIt()));
    _getIt.registerLazySingleton(() => GetUserChatsUseCase(_getIt()));
    _getIt.registerLazySingleton(() => GetChatMessagesUseCase(_getIt()));
    _getIt.registerLazySingleton(() => SendMessageUseCase(_getIt()));
    _getIt.registerLazySingleton(() => MarkMessagesReadUseCase(_getIt()));
  }
  
  /// Register BLoCs
  static Future<void> _registerBlocs() async {
    // Auth BLoC - Register as singleton to ensure same instance everywhere
    print('🔧 SERVICE_LOCATOR: Registering AuthBloc singleton...');
    _getIt.registerLazySingleton(
      () {
        print('🔧 SERVICE_LOCATOR: Creating AuthBloc singleton instance...');
        final authBloc = AuthBloc(
          signInUseCase: _getIt(),
          signUpUseCase: _getIt(),
          signOutUseCase: _getIt(),
          authRepository: _getIt(),
        );
        print('🔧 SERVICE_LOCATOR: AuthBloc singleton instance created successfully');
        print('🔧 SERVICE_LOCATOR: Adding AuthStarted event to AuthBloc...');
        authBloc.add(AuthStarted());
        print('🔧 SERVICE_LOCATOR: AuthStarted event added to AuthBloc');
        return authBloc;
      },
    );
    print('🔧 SERVICE_LOCATOR: AuthBloc singleton registered');
    
    // Matching BLoC
    _getIt.registerFactory(
      () => MatchingBloc(
        swipeUserUseCase: _getIt(),
        getMatchesUseCase: _getIt(),
        watchMatchesUseCase: _getIt(),
        unmatchUseCase: _getIt(),
      ),
    );
    
    // Chat BLoC - Register as singleton to maintain stream subscriptions
    _getIt.registerLazySingleton(
      () => ChatBloc(
        createChatUseCase: _getIt(),
        getUserChatsUseCase: _getIt(),
        getChatMessagesUseCase: _getIt(),
        sendMessageUseCase: _getIt(),
        markMessagesReadUseCase: _getIt(),
        chatRepository: _getIt(),
      ),
    );
  }
  
  /// Reset all dependencies (useful for testing)
  static void reset() {
    _getIt.reset();
  }
}