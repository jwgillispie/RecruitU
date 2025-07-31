import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/config/firebase_config.dart';
import 'core/navigation/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('🚀 MAIN: Starting app initialization...');
    
    // Load environment variables
    print('🚀 MAIN: Loading environment variables...');
    await dotenv.load(fileName: ".env");
    print('🚀 MAIN: Environment variables loaded');
    
    // Initialize Firebase
    print('🚀 MAIN: Initializing Firebase...');
    await FirebaseConfig.initialize();
    print('🚀 MAIN: Firebase initialized');
    
    // Initialize Hive for local storage
    print('🚀 MAIN: Initializing Hive...');
    await Hive.initFlutter();
    print('🚀 MAIN: Hive initialized');
    
    // Initialize dependency injection
    print('🚀 MAIN: Initializing Service Locator...');
    await ServiceLocator.init();
    print('🚀 MAIN: Service Locator initialized');
    
    // Run the app
    print('🚀 MAIN: Starting RecruitUApp...');
    runApp(const RecruitUApp());
  } catch (e) {
    print('🚀 MAIN: Error during initialization: $e');
    print('🚀 MAIN: Error type: ${e.runtimeType}');
    // Show error dialog or fallback UI
    runApp(ErrorApp(error: e.toString()));
  }
}

/// Main RecruitU Application
class RecruitUApp extends StatelessWidget {
  const RecruitUApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🚀 MAIN: Building RecruitUApp...');
    return BlocProvider.value(
      value: ServiceLocator.instance<AuthBloc>(),
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: RecruitUTheme.lightTheme,
        darkTheme: RecruitUTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.createRouter(),
      ),
    );
  }
}


/// Error app widget for initialization failures
class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecruitU - Error',
      theme: RecruitUTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: RecruitUColors.error,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Failed to start RecruitU',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}