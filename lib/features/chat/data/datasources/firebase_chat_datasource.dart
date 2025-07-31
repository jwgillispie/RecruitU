import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../../domain/entities/message_entity.dart';

/// Firebase data source for chat operations
class FirebaseChatDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  FirebaseChatDataSource({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  // Collection references
  CollectionReference get _chatsCollection => _firestore.collection('chats');
  CollectionReference _messagesCollection(String chatId) => 
      _chatsCollection.doc(chatId).collection('messages');

  /// Create a new chat between two users
  Future<ChatModel> createChat({
    required String matchId,
    required String user1Id,
    required String user1Name,
    required String user1Avatar,
    required String user2Id,
    required String user2Name,
    required String user2Avatar,
  }) async {
    try {
      final chatId = _uuid.v4();
      final now = DateTime.now();

      final chatData = ChatModel(
        id: chatId,
        matchId: matchId,
        participantIds: [user1Id, user2Id],
        participantNames: {
          user1Id: user1Name,
          user2Id: user2Name,
        },
        participantAvatars: {
          user1Id: user1Avatar,
          user2Id: user2Avatar,
        },
        unreadCounts: {
          user1Id: 0,
          user2Id: 0,
        },
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      await _chatsCollection.doc(chatId).set(chatData.toFirestore());

      // Create a welcome system message
      await sendMessage(
        chatId: chatId,
        senderId: 'system',
        senderName: 'RecruitU',
        content: 'You matched! Start your conversation here.',
        type: 'system',
      );

      return chatData;
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  /// Get chat by ID
  Future<ChatModel?> getChatById(String chatId) async {
    try {
      final doc = await _chatsCollection.doc(chatId).get();
      if (!doc.exists) return null;
      
      return ChatModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get chat: $e');
    }
  }

  /// Get chat by match ID
  Future<ChatModel?> getChatByMatchId(String matchId) async {
    try {
      final query = await _chatsCollection
          .where('matchId', isEqualTo: matchId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      
      return ChatModel.fromFirestore(query.docs.first);
    } catch (e) {
      throw Exception('Failed to get chat by match ID: $e');
    }
  }

  /// Get all chats for a user
  Stream<List<ChatModel>> getUserChats(String userId) {
    try {
      print('🔍 FIREBASE_CHAT_DATASOURCE: Getting chats for userId: $userId');
      
      return _chatsCollection
          .where('participantIds', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            print('🔍 FIREBASE_CHAT_DATASOURCE: Received snapshot with ${snapshot.docs.length} documents');
            final chats = snapshot.docs
                .map((doc) {
                  try {
                    return ChatModel.fromFirestore(doc);
                  } catch (e) {
                    print('🚨 FIREBASE_CHAT_DATASOURCE: Error parsing chat document ${doc.id}: $e');
                    return null;
                  }
                })
                .where((chat) => chat != null)
                .cast<ChatModel>()
                .toList();
            print('🔍 FIREBASE_CHAT_DATASOURCE: Successfully parsed ${chats.length} chats');
            return chats;
          });
    } catch (e) {
      print('🚨 FIREBASE_CHAT_DATASOURCE: Exception in getUserChats: $e');
      throw Exception('Failed to get user chats: $e');
    }
  }

  /// Send a message
  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    String type = 'text',
    String? replyToMessageId,
    String? mediaUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final messageId = _uuid.v4();
      final now = DateTime.now();

      final messageData = MessageModel(
        id: messageId,
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        type: _parseMessageType(type),
        timestamp: now,
        isRead: false,
        replyToMessageId: replyToMessageId,
        mediaUrl: mediaUrl,
        metadata: metadata,
      );

      // Add message to messages subcollection
      await _messagesCollection(chatId)
          .doc(messageId)
          .set(messageData.toFirestore());

      // Update chat with last message and timestamp
      await _updateChatLastMessage(chatId, messageData, senderId);

      return messageData;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get messages for a chat
  Stream<List<MessageModel>> getChatMessages(String chatId, {int limit = 50}) {
    try {
      return _messagesCollection(chatId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to get chat messages: $e');
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
    required List<String> messageIds,
  }) async {
    try {
      final batch = _firestore.batch();

      // Mark individual messages as read
      for (final messageId in messageIds) {
        final messageRef = _messagesCollection(chatId).doc(messageId);
        batch.update(messageRef, {'isRead': true});
      }

      // Reset unread count for the user in the chat
      final chatRef = _chatsCollection.doc(chatId);
      batch.update(chatRef, {
        'unreadCounts.$userId': 0,
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _messagesCollection(chatId).doc(messageId).delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  /// Delete/deactivate a chat
  Future<void> deleteChat(String chatId) async {
    try {
      await _chatsCollection.doc(chatId).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  /// Update chat last message and unread counts
  Future<void> _updateChatLastMessage(
    String chatId,
    MessageModel message,
    String senderId,
  ) async {
    try {
      final chatDoc = await _chatsCollection.doc(chatId).get();
      if (!chatDoc.exists) return;

      final chatData = chatDoc.data() as Map<String, dynamic>;
      final participantIds = List<String>.from(chatData['participantIds'] ?? []);
      final currentUnreadCounts = Map<String, int>.from(chatData['unreadCounts'] ?? {});

      // Increment unread count for other participants
      for (final participantId in participantIds) {
        if (participantId != senderId) {
          currentUnreadCounts[participantId] = (currentUnreadCounts[participantId] ?? 0) + 1;
        }
      }

      // Update chat document
      await _chatsCollection.doc(chatId).update({
        'lastMessage': {
          'id': message.id,
          'senderId': message.senderId,
          'senderName': message.senderName,
          'content': message.content,
          'type': message.type.name,
          'timestamp': Timestamp.fromDate(message.timestamp),
          'isRead': message.isRead,
          'replyToMessageId': message.replyToMessageId,
          'mediaUrl': message.mediaUrl,
          'metadata': message.metadata,
        },
        'unreadCounts': currentUnreadCounts,
        'updatedAt': Timestamp.fromDate(message.timestamp),
      });
    } catch (e) {
      throw Exception('Failed to update chat last message: $e');
    }
  }

  /// Search messages in a chat
  Stream<List<MessageModel>> searchMessages({
    required String chatId,
    required String query,
    int limit = 20,
  }) {
    try {
      return _messagesCollection(chatId)
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThan: '${query}z')
          .orderBy('content')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }

  /// Get unread message count for a user across all chats
  Future<int> getTotalUnreadCount(String userId) async {
    try {
      final query = await _chatsCollection
          .where('participantIds', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .get();

      int totalUnread = 0;
      for (final doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final unreadCounts = Map<String, int>.from(data['unreadCounts'] ?? {});
        totalUnread += unreadCounts[userId] ?? 0;
      }

      return totalUnread;
    } catch (e) {
      throw Exception('Failed to get total unread count: $e');
    }
  }

  /// Update participant info (name/avatar) across all chats
  Future<void> updateParticipantInfo({
    required String userId,
    String? newName,
    String? newAvatar,
  }) async {
    try {
      final query = await _chatsCollection
          .where('participantIds', arrayContains: userId)
          .get();

      final batch = _firestore.batch();

      for (final doc in query.docs) {
        final updates = <String, dynamic>{};
        
        if (newName != null) {
          updates['participantNames.$userId'] = newName;
        }
        
        if (newAvatar != null) {
          updates['participantAvatars.$userId'] = newAvatar;
        }

        if (updates.isNotEmpty) {
          updates['updatedAt'] = Timestamp.now();
          batch.update(doc.reference, updates);
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update participant info: $e');
    }
  }

  /// Parse message type from string
  MessageType _parseMessageType(String typeValue) {
    final typeString = typeValue.toLowerCase();
    
    switch (typeString) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'file':
        return MessageType.file;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }
}