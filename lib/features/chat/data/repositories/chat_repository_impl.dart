import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/firebase_chat_datasource.dart';

/// Implementation of ChatRepository using Firebase
class ChatRepositoryImpl implements ChatRepository {
  final FirebaseChatDataSource _dataSource;

  ChatRepositoryImpl({
    required FirebaseChatDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<ChatEntity> createChat({
    required String matchId,
    required String user1Id,
    required String user1Name,
    required String user1Avatar,
    required String user2Id,
    required String user2Name,
    required String user2Avatar,
  }) async {
    try {
      return await _dataSource.createChat(
        matchId: matchId,
        user1Id: user1Id,
        user1Name: user1Name,
        user1Avatar: user1Avatar,
        user2Id: user2Id,
        user2Name: user2Name,
        user2Avatar: user2Avatar,
      );
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  @override
  Future<ChatEntity?> getChatById(String chatId) async {
    try {
      return await _dataSource.getChatById(chatId);
    } catch (e) {
      throw Exception('Failed to get chat by ID: $e');
    }
  }

  @override
  Future<ChatEntity?> getChatByMatchId(String matchId) async {
    try {
      return await _dataSource.getChatByMatchId(matchId);
    } catch (e) {
      throw Exception('Failed to get chat by match ID: $e');
    }
  }

  @override
  Stream<List<ChatEntity>> getUserChats(String userId) {
    try {
      return _dataSource.getUserChats(userId);
    } catch (e) {
      throw Exception('Failed to get user chats: $e');
    }
  }

  @override
  Future<MessageEntity> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    String? mediaUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      return await _dataSource.sendMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        type: type.name,
        replyToMessageId: replyToMessageId,
        mediaUrl: mediaUrl,
        metadata: metadata,
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Stream<List<MessageEntity>> getChatMessages(String chatId, {int limit = 50}) {
    try {
      return _dataSource.getChatMessages(chatId, limit: limit);
    } catch (e) {
      throw Exception('Failed to get chat messages: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
    required List<String> messageIds,
  }) async {
    try {
      await _dataSource.markMessagesAsRead(
        chatId: chatId,
        userId: userId,
        messageIds: messageIds,
      );
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _dataSource.deleteMessage(chatId, messageId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  @override
  Future<void> deleteChat(String chatId) async {
    try {
      await _dataSource.deleteChat(chatId);
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  @override
  Stream<List<MessageEntity>> searchMessages({
    required String chatId,
    required String query,
    int limit = 20,
  }) {
    try {
      return _dataSource.searchMessages(
        chatId: chatId,
        query: query,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }

  @override
  Future<int> getTotalUnreadCount(String userId) async {
    try {
      return await _dataSource.getTotalUnreadCount(userId);
    } catch (e) {
      throw Exception('Failed to get total unread count: $e');
    }
  }

  @override
  Future<void> updateParticipantInfo({
    required String userId,
    String? newName,
    String? newAvatar,
  }) async {
    try {
      await _dataSource.updateParticipantInfo(
        userId: userId,
        newName: newName,
        newAvatar: newAvatar,
      );
    } catch (e) {
      throw Exception('Failed to update participant info: $e');
    }
  }
}