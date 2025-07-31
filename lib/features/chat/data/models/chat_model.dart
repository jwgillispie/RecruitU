import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import 'message_model.dart';

/// Chat model for Firebase Firestore integration
class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.matchId,
    required super.participantIds,
    required super.participantNames,
    required super.participantAvatars,
    super.lastMessage,
    required super.unreadCounts,
    required super.createdAt,
    required super.updatedAt,
    super.isActive,
    super.metadata,
  });

  /// Create ChatModel from ChatEntity
  factory ChatModel.fromEntity(ChatEntity entity) {
    return ChatModel(
      id: entity.id,
      matchId: entity.matchId,
      participantIds: entity.participantIds,
      participantNames: entity.participantNames,
      participantAvatars: entity.participantAvatars,
      lastMessage: entity.lastMessage,
      unreadCounts: entity.unreadCounts,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      metadata: entity.metadata,
    );
  }

  /// Create ChatModel from Firestore document
  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ChatModel(
      id: doc.id,
      matchId: data['matchId'] ?? '',
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: Map<String, String>.from(data['participantNames'] ?? {}),
      participantAvatars: Map<String, String>.from(data['participantAvatars'] ?? {}),
      lastMessage: data['lastMessage'] != null 
          ? _parseLastMessage(data['lastMessage'], doc.id)
          : null,
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      metadata: data['metadata'] != null 
          ? Map<String, dynamic>.from(data['metadata'])
          : null,
    );
  }

  /// Create ChatModel from JSON map
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      matchId: json['matchId'] ?? '',
      participantIds: List<String>.from(json['participantIds'] ?? []),
      participantNames: Map<String, String>.from(json['participantNames'] ?? {}),
      participantAvatars: Map<String, String>.from(json['participantAvatars'] ?? {}),
      lastMessage: json['lastMessage'] != null 
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
      unreadCounts: Map<String, int>.from(json['unreadCounts'] ?? {}),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
      'lastMessage': lastMessage != null 
          ? MessageModel.fromEntity(lastMessage!).toJson()
          : null,
      'unreadCounts': unreadCounts,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Firestore handles document ID separately
    return json;
  }

  /// Parse last message from Firestore data
  static MessageEntity? _parseLastMessage(Map<String, dynamic> messageData, String chatId) {
    try {
      return MessageModel(
        id: messageData['id'] ?? '',
        chatId: chatId,
        senderId: messageData['senderId'] ?? '',
        senderName: messageData['senderName'] ?? '',
        content: messageData['content'] ?? '',
        type: _parseMessageType(messageData['type']),
        timestamp: messageData['timestamp'] != null 
            ? (messageData['timestamp'] as Timestamp).toDate()
            : DateTime.now(),
        isRead: messageData['isRead'] ?? false,
        replyToMessageId: messageData['replyToMessageId'],
        mediaUrl: messageData['mediaUrl'],
        metadata: messageData['metadata'] != null 
            ? Map<String, dynamic>.from(messageData['metadata'])
            : null,
      );
    } catch (e) {
      print('Error parsing last message: $e');
      return null;
    }
  }

  /// Parse message type from string
  static MessageType _parseMessageType(dynamic typeValue) {
    if (typeValue == null) return MessageType.text;
    
    final typeString = typeValue.toString().toLowerCase();
    
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

  /// Create a copy with updated fields
  @override
  ChatModel copyWith({
    String? id,
    String? matchId,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String>? participantAvatars,
    MessageEntity? lastMessage,
    Map<String, int>? unreadCounts,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return ChatModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantAvatars: participantAvatars ?? this.participantAvatars,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}