import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/message_entity.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/chat_app_bar.dart';

/// Main chat screen for conversation between matched users  
class ChatScreen extends StatefulWidget {
  final String chatId;
  final String matchId;
  final String otherUserName;
  final String? otherUserAvatar;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.matchId,
    required this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  late ChatBloc _chatBloc;
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  String? _currentUserId;
  String? _currentUserName;
  List<MessageEntity> _messages = [];
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupControllers();
    _initializeChat();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  void _setupControllers() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _initializeChat() {
    _chatBloc = ServiceLocator.instance<ChatBloc>();
    
    // Get current user info
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
      _currentUserName = authState.user.displayName;
    }

    // Start watching messages for this chat
    _chatBloc.add(WatchChatMessages(widget.chatId));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _messages.length >= 50) {
        _loadMoreMessages();
      }
    }
  }

  void _loadMoreMessages() {
    setState(() {
      _isLoadingMore = true;
    });
    
    // Load more messages with higher limit
    _chatBloc.add(WatchChatMessages(widget.chatId, limit: _messages.length + 50));
    
    // Reset loading state after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  void _sendMessage(String content, {MessageType type = MessageType.text}) {
    if (_currentUserId == null || _currentUserName == null) return;
    
    if (content.trim().isEmpty && type == MessageType.text) return;

    _chatBloc.add(SendMessage(
      chatId: widget.chatId,
      senderId: _currentUserId!,
      senderName: _currentUserName!,
      content: content.trim(),
      type: type,
    ));
  }

  void _markMessagesAsRead() {
    if (_currentUserId == null) return;

    final unreadMessages = _messages
        .where((msg) => !msg.isRead && msg.senderId != _currentUserId)
        .map((msg) => msg.id)
        .toList();

    if (unreadMessages.isNotEmpty) {
      _chatBloc.add(MarkMessagesAsRead(
        chatId: widget.chatId,
        userId: _currentUserId!,
        messageIds: unreadMessages,
      ));
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    _chatBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: ChatAppBar(
          otherUserName: widget.otherUserName,
          otherUserAvatar: widget.otherUserAvatar,
          onAvatarTap: () {
            // TODO: Navigate to profile view
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile view coming soon!'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
          },
          onInfoTap: () {
            _showChatInfo();
          },
        ),
        body: BlocListener<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatMessagesLoaded) {
              setState(() {
                _messages = state.messages;
              });
              _markMessagesAsRead();
            } else if (state is ChatCombinedState) {
              if (state.currentChatId == widget.chatId) {
                setState(() {
                  _messages = state.currentMessages;
                });
                _markMessagesAsRead();
              }
            } else if (state is MessageSent) {
              // Scroll to bottom when message is sent
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
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
            child: Column(
              children: [
                // Messages list
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      if (state is ChatLoading && _messages.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4CAF50),
                          ),
                        );
                      }

                      if (_messages.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildMessagesList();
                    },
                  ),
                ),
                
                // Message input
                MessageInput(
                  onSendMessage: _sendMessage,
                  onSendImage: () => _sendMessage('', type: MessageType.image),
                  onSendVideo: () => _sendMessage('', type: MessageType.video),
                ),
              ],
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
            width: 100,
            height: 100,
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
              size: 50,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start the conversation!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Say hello to ${widget.otherUserName}',
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the top
        if (_isLoadingMore && index == _messages.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
                strokeWidth: 2,
              ),
            ),
          );
        }

        final message = _messages[index];
        final isMe = message.senderId == _currentUserId;
        final previousMessage = index < _messages.length - 1 
            ? _messages[index + 1] 
            : null;
        final nextMessage = index > 0 
            ? _messages[index - 1] 
            : null;

        // Group messages by sender and time
        final showSenderInfo = previousMessage == null ||
            previousMessage.senderId != message.senderId ||
            message.timestamp.difference(previousMessage.timestamp).inMinutes > 5;

        final showTimestamp = nextMessage == null ||
            nextMessage.senderId != message.senderId ||
            nextMessage.timestamp.difference(message.timestamp).inMinutes > 5;

        return MessageBubble(
          message: message,
          isMe: isMe,
          showSenderInfo: showSenderInfo && !isMe,
          showTimestamp: showTimestamp,
          onTap: () => _onMessageTap(message),
          onLongPress: () => _onMessageLongPress(message),
        );
      },
    );
  }

  void _onMessageTap(MessageEntity message) {
    // Handle message tap (e.g., show full image for image messages)
    if (message.type == MessageType.image && message.mediaUrl != null) {
      _showImageViewer(message.mediaUrl!);
    }
  }

  void _onMessageLongPress(MessageEntity message) {
    HapticFeedback.mediumImpact();
    _showMessageOptions(message);
  }

  void _showImageViewer(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.broken_image,
                    color: Color(0xFF9E9E9E),
                    size: 50,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(MessageEntity message) {
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
            if (message.senderId == _currentUserId) ...[
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Message', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.copy, color: Color(0xFF4CAF50)),
              title: const Text('Copy Text', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message copied to clipboard'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMessage(MessageEntity message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Message', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this message? This action cannot be undone.',
          style: TextStyle(color: Color(0xFF9E9E9E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _chatBloc.add(DeleteMessage(widget.chatId, message.id));
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

  void _showChatInfo() {
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
              'Chat with ${widget.otherUserName}',
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
              leading: const Icon(Icons.search, color: Color(0xFF2196F3)),
              title: const Text('Search Messages', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement message search
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block User', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement user blocking
              },
            ),
          ],
        ),
      ),
    );
  }
}