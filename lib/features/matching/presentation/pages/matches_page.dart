import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../shared/widgets/bottom_navigation_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/bloc/chat_event.dart';
import '../../../chat/presentation/bloc/chat_state.dart';
import '../../domain/entities/match_entity.dart';
import '../widgets/match_list_item.dart';
import '../bloc/matching_bloc.dart';
import '../bloc/matching_event.dart';
import '../bloc/matching_state.dart';

/// Page displaying user's matches with chat preview
class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late MatchingBloc _matchingBloc;
  late ChatBloc _chatBloc;
  
  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserAvatar;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupMatchingBloc();
    _loadUserAndMatches();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
  }

  void _setupMatchingBloc() {
    _matchingBloc = ServiceLocator.instance<MatchingBloc>();
    _chatBloc = ServiceLocator.instance<ChatBloc>();
  }

  void _loadUserAndMatches() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _currentUserId = authState.user.id;
        _currentUserName = authState.user.displayName;
        _currentUserAvatar = authState.user.profileImageUrl;
      });
      // Load matches using the real matching system
      _matchingBloc.add(WatchMatches(authState.user.id));
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    _matchingBloc.close();
    _chatBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'Matches',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: BlocBuilder<MatchingBloc, MatchingState>(
              bloc: _matchingBloc,
              builder: (context, state) {
                if (state is MatchingLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                  );
                } else if (state is MatchingError) {
                  return Center(
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
                          'Error loading matches',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: const TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentUserId != null) {
                              _matchingBloc.add(LoadMatches(_currentUserId!));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is MatchingLoaded) {
                  if (state.matches.isEmpty) {
                    return _buildEmptyState();
                  } else {
                    return _buildMatchesList(state.matches);
                  }
                }
                return _buildEmptyState();
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const RecruitUBottomNavigationBar(currentIndex: 2),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.favorite_outline,
              size: 60,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Matches Yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Start swiping in Discovery to find\nyour perfect matches!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to discovery
              Navigator.of(context).pushNamed('/discovery');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Start Discovering',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList(List<MatchEntity> matches) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_currentUserId != null) {
          _matchingBloc.add(LoadMatches(_currentUserId!));
        }
      },
      backgroundColor: const Color(0xFF1A1A1A),
      color: const Color(0xFF4CAF50),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeOutBack,
            transform: Matrix4.translationValues(
              0,
              _fadeAnimation.value == 1.0 ? 0 : 50,
              0,
            ),
            child: MatchListItem(
              match: match,
              currentUserId: _currentUserId ?? '',
              onTap: () {
                _onMatchTapped(match);
              },
              onLongPress: () {
                _showMatchOptions(match);
              },
            ),
          );
        },
      ),
    );
  }

  void _onMatchTapped(MatchEntity match) {
    if (_currentUserId == null || _currentUserName == null) return;
    
    final otherUserId = match.getOtherUserId(_currentUserId!);
    final otherUserName = match.getOtherUserName(_currentUserId!);
    final otherUserAvatar = match.getOtherUserProfileImage(_currentUserId!);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
      ),
    );

    // Check if chat already exists or create new one
    _chatBloc.add(GetChatByMatchId(match.id));
    
    // Listen for chat creation result
    late StreamSubscription subscription;
    subscription = _chatBloc.stream.listen((state) {
      if (state is ChatCreated) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          context.go('/chat/${state.chat.id}', extra: {
            'matchId': match.id,
            'otherUserName': otherUserName,
            'otherUserAvatar': otherUserAvatar,
          });
        }
        subscription.cancel();
      } else if (state is ChatError) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          if (state.message.contains('Chat not found')) {
            // Create new chat
            _chatBloc.add(CreateChat(
              matchId: match.id,
              user1Id: _currentUserId!,
              user1Name: _currentUserName!,
              user1Avatar: _currentUserAvatar ?? '',
              user2Id: otherUserId,
              user2Name: otherUserName,
              user2Avatar: otherUserAvatar ?? '',
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to open chat: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
            subscription.cancel();
          }
        } else {
          subscription.cancel();
        }
      }
    });
    
    // Cancel subscription after a timeout
    Future.delayed(const Duration(seconds: 10), () {
      subscription.cancel();
    });
  }

  void _showMatchOptions(MatchEntity match) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF9E9E9E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              match.getOtherUserName(_currentUserId ?? ''),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFF4CAF50)),
              title: const Text('Send Message', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _onMatchTapped(match);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF2196F3)),
              title: const Text('View Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile view
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Unmatch', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showUnmatchConfirmation(match);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUnmatchConfirmation(MatchEntity match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unmatch?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to unmatch with ${match.getOtherUserName(_currentUserId ?? '')}? This action cannot be undone.',
          style: const TextStyle(color: Color(0xFF9E9E9E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _matchingBloc.add(UnmatchUser(match.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Unmatched with ${match.getOtherUserName(_currentUserId ?? '')}'),
                  backgroundColor: const Color(0xFF1A1A1A),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Unmatch', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Filter Matches', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Filter options coming soon! You\'ll be able to sort by recent activity, unread messages, and more.',
          style: TextStyle(color: Color(0xFF9E9E9E)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}