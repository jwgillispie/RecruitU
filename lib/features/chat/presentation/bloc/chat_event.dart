import 'package:equatable/equatable.dart';
import '../../domain/entities/message_entity.dart';

/// Base class for chat events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load user's chats
class LoadUserChats extends ChatEvent {
  final String userId;

  const LoadUserChats(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to watch user's chats (real-time)
class WatchUserChats extends ChatEvent {
  final String userId;

  const WatchUserChats(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to load messages for a specific chat
class LoadChatMessages extends ChatEvent {
  final String chatId;
  final int limit;

  const LoadChatMessages(this.chatId, {this.limit = 50});

  @override
  List<Object?> get props => [chatId, limit];
}

/// Event to watch messages for a specific chat (real-time)
class WatchChatMessages extends ChatEvent {
  final String chatId;
  final int limit;

  const WatchChatMessages(this.chatId, {this.limit = 50});

  @override
  List<Object?> get props => [chatId, limit];
}

/// Event to send a message
class SendMessage extends ChatEvent {
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final String? replyToMessageId;
  final String? mediaUrl;
  final Map<String, dynamic>? metadata;

  const SendMessage({
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.type = MessageType.text,
    this.replyToMessageId,
    this.mediaUrl,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        chatId,
        senderId,
        senderName,
        content,
        type,
        replyToMessageId,
        mediaUrl,
        metadata,
      ];
}

/// Event to create a new chat
class CreateChat extends ChatEvent {
  final String matchId;
  final String user1Id;
  final String user1Name;
  final String user1Avatar;
  final String user2Id;
  final String user2Name;
  final String user2Avatar;

  const CreateChat({
    required this.matchId,
    required this.user1Id,
    required this.user1Name,
    required this.user1Avatar,
    required this.user2Id,
    required this.user2Name,
    required this.user2Avatar,
  });

  @override
  List<Object?> get props => [
        matchId,
        user1Id,
        user1Name,
        user1Avatar,
        user2Id,
        user2Name,
        user2Avatar,
      ];
}

/// Event to mark messages as read
class MarkMessagesAsRead extends ChatEvent {
  final String chatId;
  final String userId;
  final List<String> messageIds;

  const MarkMessagesAsRead({
    required this.chatId,
    required this.userId,
    required this.messageIds,
  });

  @override
  List<Object?> get props => [chatId, userId, messageIds];
}

/// Event to delete a message
class DeleteMessage extends ChatEvent {
  final String chatId;
  final String messageId;

  const DeleteMessage(this.chatId, this.messageId);

  @override
  List<Object?> get props => [chatId, messageId];
}

/// Event to delete a chat
class DeleteChat extends ChatEvent {
  final String chatId;

  const DeleteChat(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Event to search messages in a chat
class SearchMessages extends ChatEvent {
  final String chatId;
  final String query;
  final int limit;

  const SearchMessages({
    required this.chatId,
    required this.query,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [chatId, query, limit];
}

/// Event to get chat by match ID
class GetChatByMatchId extends ChatEvent {
  final String matchId;

  const GetChatByMatchId(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

/// Event to clear current chat (when navigating away)
class ClearCurrentChat extends ChatEvent {
  const ClearCurrentChat();
}

/// Event to clear error state
class ClearChatError extends ChatEvent {
  const ClearChatError();
}