import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';

/// Base class for chat states
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Loading state
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// State when chats are successfully loaded
class ChatsLoaded extends ChatState {
  final List<ChatEntity> chats;
  final String? currentChatId;

  const ChatsLoaded({
    required this.chats,
    this.currentChatId,
  });

  @override
  List<Object?> get props => [chats, currentChatId];

  ChatsLoaded copyWith({
    List<ChatEntity>? chats,
    String? currentChatId,
  }) {
    return ChatsLoaded(
      chats: chats ?? this.chats,
      currentChatId: currentChatId ?? this.currentChatId,
    );
  }
}

/// State when messages for a chat are loaded
class ChatMessagesLoaded extends ChatState {
  final String chatId;
  final List<MessageEntity> messages;
  final ChatEntity? chat;
  final bool hasMore;

  const ChatMessagesLoaded({
    required this.chatId,
    required this.messages,
    this.chat,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [chatId, messages, chat, hasMore];

  ChatMessagesLoaded copyWith({
    String? chatId,
    List<MessageEntity>? messages,
    ChatEntity? chat,
    bool? hasMore,
  }) {
    return ChatMessagesLoaded(
      chatId: chatId ?? this.chatId,
      messages: messages ?? this.messages,
      chat: chat ?? this.chat,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// State when a message is being sent
class MessageSending extends ChatState {
  final String chatId;
  final String tempMessageId;
  final MessageEntity pendingMessage;

  const MessageSending({
    required this.chatId,
    required this.tempMessageId,
    required this.pendingMessage,
  });

  @override
  List<Object?> get props => [chatId, tempMessageId, pendingMessage];
}

/// State when a message is successfully sent
class MessageSent extends ChatState {
  final MessageEntity message;

  const MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when a chat is successfully created
class ChatCreated extends ChatState {
  final ChatEntity chat;

  const ChatCreated(this.chat);

  @override
  List<Object?> get props => [chat];
}

/// State when messages are successfully marked as read
class MessagesMarkedAsRead extends ChatState {
  final String chatId;
  final List<String> messageIds;

  const MessagesMarkedAsRead({
    required this.chatId,
    required this.messageIds,
  });

  @override
  List<Object?> get props => [chatId, messageIds];
}

/// State when a message is successfully deleted
class MessageDeleted extends ChatState {
  final String chatId;
  final String messageId;

  const MessageDeleted({
    required this.chatId,
    required this.messageId,
  });

  @override
  List<Object?> get props => [chatId, messageId];
}

/// State when a chat is successfully deleted
class ChatDeleted extends ChatState {
  final String chatId;

  const ChatDeleted(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// State when messages are found through search
class MessagesSearchResults extends ChatState {
  final String chatId;
  final String query;
  final List<MessageEntity> results;

  const MessagesSearchResults({
    required this.chatId,
    required this.query,
    required this.results,
  });

  @override
  List<Object?> get props => [chatId, query, results];
}

/// Combined state for chats list and current chat messages
class ChatCombinedState extends ChatState {
  final List<ChatEntity> chats;
  final String? currentChatId;
  final List<MessageEntity> currentMessages;
  final ChatEntity? currentChat;
  final bool hasMoreMessages;
  final bool isLoadingMessages;

  const ChatCombinedState({
    required this.chats,
    this.currentChatId,
    required this.currentMessages,
    this.currentChat,
    this.hasMoreMessages = true,
    this.isLoadingMessages = false,
  });

  @override
  List<Object?> get props => [
        chats,
        currentChatId,
        currentMessages,
        currentChat,
        hasMoreMessages,
        isLoadingMessages,
      ];

  ChatCombinedState copyWith({
    List<ChatEntity>? chats,
    String? currentChatId,
    List<MessageEntity>? currentMessages,
    ChatEntity? currentChat,
    bool? hasMoreMessages,
    bool? isLoadingMessages,
  }) {
    return ChatCombinedState(
      chats: chats ?? this.chats,
      currentChatId: currentChatId ?? this.currentChatId,
      currentMessages: currentMessages ?? this.currentMessages,
      currentChat: currentChat ?? this.currentChat,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
    );
  }
}

/// Error state
class ChatError extends ChatState {
  final String message;
  final String? errorCode;

  const ChatError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}