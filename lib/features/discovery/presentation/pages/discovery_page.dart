import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../shared/widgets/bottom_navigation_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../profile/domain/entities/player_profile_entity.dart';
import '../../../profile/domain/entities/coach_profile_entity.dart';
import '../../../profile/domain/usecases/get_profiles_for_discovery_usecase.dart';
import '../../../matching/domain/entities/swipe_action_entity.dart';
import '../../../matching/presentation/bloc/matching_bloc.dart';
import '../../../matching/presentation/bloc/matching_event.dart';
import '../../../matching/presentation/bloc/matching_state.dart';
import '../widgets/player_discovery_card.dart';
import '../widgets/coach_discovery_card.dart';
import '../widgets/discovery_filters.dart';

/// Discovery page for browsing profiles based on user type
class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _cardAnimation;
  late Animation<double> _buttonAnimation;
  late MatchingBloc _matchingBloc;
  
  UserType? _currentUserType;
  String? _currentUserId;
  List<dynamic> _profiles = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _showFilters = false;

  // Filter state
  List<SoccerPosition> _selectedPositions = [];
  List<DivisionLevel> _selectedDivisions = [];
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupMatchingBloc();
    _loadUserTypeAndProfiles();
  }

  void _setupAnimations() {
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOut,
    ));

    _buttonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));

    _cardAnimationController.forward();
  }

  void _setupMatchingBloc() {
    _matchingBloc = ServiceLocator.instance<MatchingBloc>();
  }

  void _loadUserTypeAndProfiles() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _currentUserType = authState.user.userType;
        _currentUserId = authState.user.id;
      });
      _loadRealProfiles();
    }
  }

  Future<void> _loadRealProfiles() async {
    if (_currentUserId == null || _currentUserType == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final discoveryUseCase = ServiceLocator.instance<GetProfilesForDiscoveryUseCase>();
      
      // Load profiles based on user type
      if (_currentUserType == UserType.coach) {
        final profiles = await discoveryUseCase.getPlayerProfiles(
          coachUserId: _currentUserId!,
          limit: 20,
        );
        setState(() {
          _profiles = profiles;
        });
      } else if (_currentUserType == UserType.player) {
        final profiles = await discoveryUseCase.getCoachProfiles(
          playerUserId: _currentUserId!,
          limit: 20,
        );
        setState(() {
          _profiles = profiles;
        });
      }
    } catch (e) {
      print('Error loading profiles: $e');
      // Show empty profiles on error
      setState(() {
        _profiles = [];
      });
    }

    setState(() {
      _isLoading = false;
      _currentIndex = 0;
    });
  }


  void _onSwipeLeft() {
    _performSwipeAction(SwipeAction.pass);
  }

  void _onSwipeRight() {
    _performSwipeAction(SwipeAction.like);
  }

  void _performSwipeAction(SwipeAction action) {
    if (_currentUserId == null || _currentIndex >= _profiles.length) {
      return;
    }

    final currentProfile = _profiles[_currentIndex];
    String targetUserId = '';
    
    if (currentProfile is PlayerProfileEntity) {
      targetUserId = currentProfile.userId;
    } else if (currentProfile is CoachProfileEntity) {
      targetUserId = currentProfile.userId;
    }

    if (targetUserId.isEmpty) {
      return;
    }

    // Add swipe event to matching bloc
    _matchingBloc.add(SwipeUser(
      fromUserId: _currentUserId!,
      toUserId: targetUserId,
      action: action,
    ));

    _animateCardExit(() {
      _nextProfile();
    });
  }

  void _animateCardExit(VoidCallback onComplete) {
    _cardAnimationController.reverse().then((_) {
      onComplete();
      _cardAnimationController.forward();
    });
  }

  void _nextProfile() {
    if (_currentIndex < _profiles.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _showNoMoreProfilesDialog();
    }
  }

  void _showMatchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.favorite, color: Color(0xFF4CAF50), size: 30),
            SizedBox(width: 10),
            Text('It\'s a Match!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'You and this profile are interested in each other. You can now start a conversation!',
          style: TextStyle(color: Color(0xFF9E9E9E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Browsing', style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to chat
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Start Chat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNoMoreProfilesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('No More Profiles', style: TextStyle(color: Colors.white)),
        content: const Text(
          'You\'ve seen all available profiles. Check back later for new matches!',
          style: TextStyle(color: Color(0xFF9E9E9E)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _loadRealProfiles();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Refresh', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _buttonAnimationController.dispose();
    _matchingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MatchingBloc, MatchingState>(
      bloc: _matchingBloc,
      listener: (context, state) {
        if (state is SwipeSuccess && state.isMatch) {
          _showMatchDialog();
        } else if (state is SwipeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          _currentUserType == UserType.coach ? 'Discover Players' : 'Discover Coaches',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
              color: _showFilters ? const Color(0xFF4CAF50) : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters)
            DiscoveryFilters(
              selectedPositions: _selectedPositions,
              selectedDivisions: _selectedDivisions,
              selectedRegion: _selectedRegion,
              onPositionsChanged: (positions) {
                setState(() {
                  _selectedPositions = positions;
                });
              },
              onDivisionsChanged: (divisions) {
                setState(() {
                  _selectedDivisions = divisions;
                });
              },
              onRegionChanged: (region) {
                setState(() {
                  _selectedRegion = region;
                });
              },
            ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                  )
                : _profiles.isEmpty
                    ? const Center(
                        child: Text(
                          'No profiles available',
                          style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 18),
                        ),
                      )
                    : _currentIndex >= _profiles.length
                        ? const Center(
                            child: Text(
                              'No more profiles',
                              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 18),
                            ),
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              // Current profile card
                              AnimatedBuilder(
                                animation: _cardAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _cardAnimation.value,
                                    child: Opacity(
                                      opacity: _cardAnimation.value,
                                      child: _buildProfileCard(_profiles[_currentIndex]),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
          ),
          // Action buttons
          if (!_isLoading && _profiles.isNotEmpty && _currentIndex < _profiles.length)
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pass button
                  GestureDetector(
                    onTapDown: (_) => _buttonAnimationController.forward(),
                    onTapUp: (_) => _buttonAnimationController.reverse(),
                    onTapCancel: () => _buttonAnimationController.reverse(),
                    onTap: _onSwipeLeft,
                    child: AnimatedBuilder(
                      animation: _buttonAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _buttonAnimation.value,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF424242),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF424242).withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Like button
                  GestureDetector(
                    onTapDown: (_) => _buttonAnimationController.forward(),
                    onTapUp: (_) => _buttonAnimationController.reverse(),
                    onTapCancel: () => _buttonAnimationController.reverse(),
                    onTap: _onSwipeRight,
                    child: AnimatedBuilder(
                      animation: _buttonAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _buttonAnimation.value,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: const RecruitUBottomNavigationBar(currentIndex: 1),
    ),
    );
  }

  Widget _buildProfileCard(dynamic profile) {
    if (profile is PlayerProfileEntity) {
      return PlayerDiscoveryCard(player: profile);
    } else if (profile is CoachProfileEntity) {
      return CoachDiscoveryCard(coach: profile);
    }
    return const SizedBox.shrink();
  }
}