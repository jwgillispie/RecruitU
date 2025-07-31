import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

/// Abstract repository for chat operations
abstract class ChatRepository {
  /// Create a new chat between two users
  Future<ChatEntity> createChat({
    required String matchId,
    required String user1Id,
    required String user1Name,
    required String user1Avatar,
    required String user2Id,
    required String user2Name,
    required String user2Avatar,
  });

  /// Get chat by ID
  Future<ChatEntity?> getChatById(String chatId);

  /// Get chat by match ID
  Future<ChatEntity?> getChatByMatchId(String matchId);

  /// Get all chats for a user
  Stream<List<ChatEntity>> getUserChats(String userId);

  /// Send a message
  Future<MessageEntity> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    String? mediaUrl,
    Map<String, dynamic>? metadata,
  });

  /// Get messages for a chat
  Stream<List<MessageEntity>> getChatMessages(String chatId, {int limit = 50});

  /// Mark messages as read
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
    required List<String> messageIds,
  });

  /// Delete a message
  Future<void> deleteMessage(String chatId, String messageId);

  /// Delete/deactivate a chat
  Future<void> deleteChat(String chatId);

  /// Search messages in a chat
  Stream<List<MessageEntity>> searchMessages({
    required String chatId,
    required String query,
    int limit = 20,
  });

  /// Get unread message count for a user across all chats
  Future<int> getTotalUnreadCount(String userId);

  /// Update participant info (name/avatar) across all chats
  Future<void> updateParticipantInfo({
    required String userId,
    String? newName,
    String? newAvatar,
  });
}