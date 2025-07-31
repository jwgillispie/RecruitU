import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../shared/widgets/bottom_navigation_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/chat_entity.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_list_item.dart';
import 'chat_screen.dart';

/// Page displaying all user's chats
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage>
    with TickerProviderStateMixin {
  late ChatBloc _chatBloc;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  String? _currentUserId;
  List<ChatEntity> _chats = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupChatBloc();
    // Delay chat initialization to ensure AuthBloc is accessible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChats();
    });
  }
  
  void _setupChatBloc() {
    _chatBloc = ServiceLocator.instance<ChatBloc>();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  void _initializeChats() {
    // Get current user info
    final authState = context.read<AuthBloc>().state;
    print('🔍 CHAT_LIST_PAGE: Auth state: ${authState.runtimeType}');
    
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
      print('🔍 CHAT_LIST_PAGE: User ID: $_currentUserId');
      // Start watching user's chats
      _chatBloc.add(WatchUserChats(_currentUserId!));
      print('🔍 CHAT_LIST_PAGE: WatchUserChats event added');
    } else {
      print('🚨 CHAT_LIST_PAGE: User not authenticated, cannot load chats');
      // Show an error or redirect to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to view your messages'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    // Don't close the ChatBloc since it's a singleton - let the service locator manage it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A1A),
          elevation: 0,
          title: const Text(
            'Messages',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Color(0xFF9E9E9E),
              ),
              onPressed: () {
                _showSearch();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFF9E9E9E),
              ),
              onPressed: () {
                _showOptions();
              },
            ),
          ],
        ),
        body: BlocListener<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatsLoaded) {
              setState(() {
                _chats = state.chats;
              });
            } else if (state is ChatCombinedState) {
              setState(() {
                _chats = state.chats;
              });
            } else if (state is ChatError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                print('🔍 CHAT_LIST_PAGE: BlocBuilder state: ${state.runtimeType}, _chats.length: ${_chats.length}');
                
                // Show loading spinner only when ChatLoading and we have no cached chats
                if (state is ChatLoading && _chats.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4CAF50),
                    ),
                  );
                }

                // Handle ChatsLoaded state directly
                if (state is ChatsLoaded) {
                  if (state.chats.isEmpty) {
                    return _buildEmptyState();
                  } else {
                    return _buildChatsList();
                  }
                }

                // Handle error state
                if (state is ChatError && _chats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading chats',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentUserId != null) {
                              _chatBloc.add(WatchUserChats(_currentUserId!));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Show empty state when no chats are available
                if (_chats.isEmpty) {
                  return _buildEmptyState();
                }

                // Show the chats list
                return _buildChatsList();
              },
            ),
          ),
        ),
      ),
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
              Icons.chat_bubble_outline,
              size: 60,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Messages Yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Start matching with players and coaches\nto begin conversations!',
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
              context.go('/discovery');
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

  Widget _buildChatsList() {
    return RefreshIndicator(
      onRefresh: () async {
        if (_currentUserId != null) {
          _chatBloc.add(WatchUserChats(_currentUserId!));
        }
      },
      backgroundColor: const Color(0xFF1A1A1A),
      color: const Color(0xFF4CAF50),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeOutBack,
            transform: Matrix4.translationValues(
              0,
              _fadeAnimation.value == 1.0 ? 0 : 50,
              0,
            ),
            child: ChatListItem(
              chat: chat,
              currentUserId: _currentUserId ?? '',
              onTap: () => _openChat(chat),
              onLongPress: () => _showChatOptions(chat),
            ),
          );
        },
      ),
    );
  }

  void _openChat(ChatEntity chat) {
    final otherUserId = chat.getOtherParticipantId(_currentUserId ?? '');
    final otherUserName = chat.getOtherParticipantName(_currentUserId ?? '');
    final otherUserAvatar = chat.getOtherParticipantAvatar(_currentUserId ?? '');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chat.id,
          matchId: chat.matchId,
          otherUserName: otherUserName,
          otherUserAvatar: otherUserAvatar,
        ),
      ),
    );
  }

  void _showChatOptions(ChatEntity chat) {
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
              chat.getOtherParticipantName(_currentUserId ?? ''),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF4CAF50)),
              title: const Text('View Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off, color: Color(0xFF2196F3)),
              title: const Text('Mute Chat', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement mute functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Chat', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteChat(chat);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteChat(ChatEntity chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Chat', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this conversation with ${chat.getOtherParticipantName(_currentUserId ?? '')}? This action cannot be undone.',
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
              _chatBloc.add(DeleteChat(chat.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chat with ${chat.getOtherParticipantName(_currentUserId ?? '')} deleted'),
                  backgroundColor: const Color(0xFF1A1A1A),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Search Messages', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Message search functionality coming soon! You\'ll be able to search through all your conversations.',
          style: TextStyle(color: Color(0xFF9E9E9E)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Got it', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOptions() {
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
            const Text(
              'Chat Options',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.mark_chat_read, color: Color(0xFF4CAF50)),
              title: const Text('Mark All as Read', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement mark all as read
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: Color(0xFF2196F3)),
              title: const Text('Archived Chats', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show archived chats
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF9E9E9E)),
              title: const Text('Chat Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show chat settings
              },
            ),
          ],
        ),
      ),
    );
  }
}