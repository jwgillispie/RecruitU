import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/home_screen.dart';
import '../../features/profile/presentation/pages/profile_completion_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/discovery/presentation/pages/discovery_page.dart';
import '../../features/matching/presentation/pages/matches_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../constants/app_constants.dart';
import '../di/service_locator.dart';

/// Application router configuration using GoRouter
class AppRouter {
  static GoRouter createRouter() {
    print('🚦 ROUTER: Creating GoRouter...');
    print('🚦 ROUTER: Getting AuthBloc from ServiceLocator...');
    final authBloc = ServiceLocator.instance<AuthBloc>();
    print('🚦 ROUTER: AuthBloc obtained successfully');
    
    return GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(
        authBloc.stream,
      ),
      redirect: (context, state) {
        print('🚦 ROUTER: Checking redirect for ${state.matchedLocation}');
        
        final authBloc = ServiceLocator.instance<AuthBloc>();
        final authState = authBloc.state;
        
        print('🚦 ROUTER: Current auth state: ${authState.runtimeType}');
        
        // Define public routes that don't require authentication
        final publicRoutes = ['/welcome', '/login', '/signup'];
        final isPublicRoute = publicRoutes.contains(state.matchedLocation);
        
        // If we're on splash, only leave if auth is determined
        if (state.matchedLocation == '/splash') {
          if (authState is AuthAuthenticated) {
            print('🚦 ROUTER: Authenticated user leaving splash -> /home');
            return '/home';
          } else if (authState is AuthUnauthenticated) {
            print('🚦 ROUTER: Unauthenticated user leaving splash -> /welcome');
            return '/welcome';
          } else if (authState is AuthError) {
            print('🚦 ROUTER: Auth error occurred, redirecting to welcome screen');
            return '/welcome';
          }
          // Stay on splash for AuthInitial and AuthLoading
          print('🚦 ROUTER: Staying on splash, auth state: ${authState.runtimeType}');
          return null;
        }
        
        // For non-splash routes
        if (authState is AuthInitial || authState is AuthLoading) {
          print('🚦 ROUTER: Auth loading/initial - redirecting to splash');
          return '/splash';
        }
        
        if (authState is AuthAuthenticated) {
          print('🚦 ROUTER: User authenticated - checking route');
          print('🚦 ROUTER: Current location: ${state.matchedLocation}');
          print('🚦 ROUTER: Is public route: $isPublicRoute');
          print('🚦 ROUTER: User profile complete: ${authState.user.isProfileComplete}');
          
          // If user is on public route, redirect based on profile completion
          if (isPublicRoute) {
            if (!authState.user.isProfileComplete) {
              print('🚦 ROUTER: Redirecting new user to profile completion');
              return '/profile-completion';
            } else {
              print('🚦 ROUTER: Redirecting authenticated user from ${state.matchedLocation} to /home');
              return '/home';
            }
          }
          
          // If profile is not complete, only allow profile completion route
          if (!authState.user.isProfileComplete) {
            if (state.matchedLocation != '/profile-completion') {
              print('🚦 ROUTER: Profile incomplete - forcing profile completion');
              return '/profile-completion';
            }
          }
          
          // Allow authenticated users to access all routes
          print('🚦 ROUTER: Allowing authenticated user access to ${state.matchedLocation}');
          return null;
        }
        
        if (authState is AuthUnauthenticated) {
          print('🚦 ROUTER: User not authenticated');
          
          // If user is on protected route, redirect to welcome
          if (!isPublicRoute) {
            print('🚦 ROUTER: Redirecting unauthenticated user from ${state.matchedLocation} to /welcome');
            return '/welcome';
          }
          
          // Allow unauthenticated users to access public routes
          return null;
        }
        
        print('🚦 ROUTER: No redirect needed');
        return null;
      },
      routes: [
        // Splash route
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        
        // Welcome route
        GoRoute(
          path: '/welcome',
          name: 'welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        
        // Login route
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        
        // Signup route
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignUpPage(),
        ),
        
        // Home route (protected)
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        
        // Discovery route (protected)
        GoRoute(
          path: '/discovery',
          name: 'discovery',
          builder: (context, state) => const DiscoveryPage(),
        ),
        
        // Matches route (protected)
        GoRoute(
          path: '/matches',
          name: 'matches',
          builder: (context, state) => const MatchesPage(),
        ),
        
        // Profile route (protected)
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        
        // Profile completion route (protected)
        GoRoute(
          path: '/profile-completion',
          name: 'profile-completion',
          builder: (context, state) {
            final authBloc = ServiceLocator.instance<AuthBloc>();
            final authState = authBloc.state;
            
            // Get user info from auth state or fallback to extra params
            if (authState is AuthAuthenticated) {
              return ProfileCompletionPage(
                userType: authState.user.userType,
                userId: authState.user.id,
                displayName: authState.user.displayName,
              );
            } else {
              // Fallback for cases where user data is passed as extra
              final extra = state.extra as Map<String, dynamic>?;
              return ProfileCompletionPage(
                userType: extra?['userType'] ?? UserType.player,
                userId: extra?['userId'] ?? '',
                displayName: extra?['displayName'] ?? '',
              );
            }
          },
        ),
        
        // Chat list route (protected)
        GoRoute(
          path: '/chats',
          name: 'chats',
          builder: (context, state) => const ChatListPage(),
        ),
        
        // Individual chat route (protected)
        GoRoute(
          path: '/chat/:id',
          name: 'chat',
          builder: (context, state) {
            final chatId = state.pathParameters['id'] ?? '';
            final extra = state.extra as Map<String, dynamic>?;
            return ChatScreen(
              chatId: chatId,
              matchId: extra?['matchId'] ?? '',
              otherUserName: extra?['otherUserName'] ?? 'User',
              otherUserAvatar: extra?['otherUserAvatar'],
            );
          },
        ),
      ],
      
      // Error handling
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found: ${state.matchedLocation}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/welcome'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stream that refreshes GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    print('🚦 ROUTER_STREAM: Initializing GoRouter refresh stream');
    _subscription = stream.asBroadcastStream().listen((state) {
      print('🚦 ROUTER_STREAM: Auth state changed to ${state.runtimeType}, notifying GoRouter');
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    print('🚦 ROUTER_STREAM: Disposing GoRouter refresh stream');
    _subscription.cancel();
    super.dispose();
  }
}

/// Splash screen widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    
    print('🚦 SPLASH: Animation started, router will handle navigation after 1 second');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A1A),
              Color(0xFF0F1419),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                
                // App Name
                const Text(
                  'RecruitU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Tagline
                const Text(
                  'Connect. Play. Succeed.',
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 60),
                
                // Loading Indicator
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Welcome screen widget  
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A1A),
              Color(0xFF0F1419),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Title
                const Text(
                  'Welcome to RecruitU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Description
                const Text(
                  'The premier platform connecting college soccer players with coaches. Build your profile, showcase your skills, and find your perfect match.',
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 60),
                
                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () => context.go('/signup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.go('/login'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}