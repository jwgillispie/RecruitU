import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/recruitu_button.dart';
import '../../shared/widgets/bottom_navigation_bar.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/bloc/auth_event.dart';
import '../auth/presentation/bloc/auth_state.dart';
import '../profile/presentation/pages/profile_completion_page.dart';

/// Temporary home screen for authenticated users
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/welcome',
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppConstants.appName),
          backgroundColor: RecruitUColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _showSignOutDialog(context);
              },
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Message
                    Text(
                      'Welcome back, ${state.user.displayName}!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You are signed in as a ${state.user.userType.toString().split('.').last}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // User Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: RecruitUColors.primary,
                                  child: Text(
                                    state.user.displayName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.user.displayName,
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      Text(
                                        state.user.email,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            state.user.isVerified ? Icons.verified : Icons.pending,
                                            size: 16,
                                            color: state.user.isVerified 
                                                ? RecruitUColors.success 
                                                : RecruitUColors.warning,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            state.user.isVerified ? 'Verified' : 'Pending Verification',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: state.user.isVerified 
                                                  ? RecruitUColors.success 
                                                  : RecruitUColors.warning,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (state.user.userType == UserType.player) ...[
                      RecruitUButton(
                        text: 'Complete Profile',
                        icon: Icons.person,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileCompletionPage(
                                userType: state.user.userType,
                                userId: state.user.id,
                                displayName: state.user.displayName,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      RecruitUButton(
                        text: 'Find Coaches',
                        type: ButtonType.outline,
                        icon: Icons.search,
                        onPressed: () {
                          context.go('/discovery');
                        },
                      ),
                      const SizedBox(height: 12),
                      RecruitUButton(
                        text: 'View Matches',
                        type: ButtonType.outline,
                        icon: Icons.favorite,
                        onPressed: () {
                          context.go('/matches');
                        },
                      ),
                      const SizedBox(height: 12),
                      RecruitUButton(
                        text: 'Messages',
                        type: ButtonType.outline,
                        icon: Icons.chat,
                        onPressed: () {
                          context.go('/chats');
                        },
                      ),
                    ] else if (state.user.userType == UserType.coach) ...[
                      RecruitUButton(
                        text: 'Complete Program Profile',
                        icon: Icons.business,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileCompletionPage(
                                userType: state.user.userType,
                                userId: state.user.id,
                                displayName: state.user.displayName,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      RecruitUButton(
                        text: 'Browse Players',
                        type: ButtonType.outline,
                        icon: Icons.search,
                        onPressed: () {
                          context.go('/discovery');
                        },
                      ),
                      const SizedBox(height: 12),
                      RecruitUButton(
                        text: 'View Matches',
                        type: ButtonType.outline,
                        icon: Icons.favorite,
                        onPressed: () {
                          context.go('/matches');
                        },
                      ),
                      const SizedBox(height: 12),
                      RecruitUButton(
                        text: 'Messages',
                        type: ButtonType.outline,
                        icon: Icons.chat,
                        onPressed: () {
                          context.go('/chats');
                        },
                      ),
                    ],

                    const Spacer(),

                    // Sign Out Button
                    RecruitUButton(
                      text: 'Sign Out',
                      type: ButtonType.ghost,
                      icon: Icons.logout,
                      onPressed: () => _showSignOutDialog(context),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        bottomNavigationBar: const RecruitUBottomNavigationBar(currentIndex: 0),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: RecruitUColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}