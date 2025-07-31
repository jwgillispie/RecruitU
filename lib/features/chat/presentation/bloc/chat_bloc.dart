import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/create_chat_usecase.dart';
import '../../domain/usecases/get_chat_messages_usecase.dart';
import '../../domain/usecases/get_user_chats_usecase.dart';
import '../../domain/usecases/mark_messages_read_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/// BLoC for managing chat state
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final CreateChatUseCase _createChatUseCase;
  final GetUserChatsUseCase _getUserChatsUseCase;
  final GetChatMessagesUseCase _getChatMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final MarkMessagesReadUseCase _markMessagesReadUseCase;
  final ChatRepository _chatRepository;
  final Uuid _uuid;

  // Stream subscriptions
  StreamSubscription<List<ChatEntity>>? _chatsSubscription;
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;

  // Current state tracking
  List<ChatEntity> _currentChats = [];
  String? _currentChatId;
  List<MessageEntity> _currentMessages = [];
  ChatEntity? _currentChat;

  ChatBloc({
    required CreateChatUseCase createChatUseCase,
    required GetUserChatsUseCase getUserChatsUseCase,
    required GetChatMessagesUseCase getChatMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required MarkMessagesReadUseCase markMessagesReadUseCase,
    required ChatRepository chatRepository,
    Uuid? uuid,
  })  : _createChatUseCase = createChatUseCase,
        _getUserChatsUseCase = getUserChatsUseCase,
        _getChatMessagesUseCase = getChatMessagesUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _markMessagesReadUseCase = markMessagesReadUseCase,
        _chatRepository = chatRepository,
        _uuid = uuid ?? const Uuid(),
        super(const ChatInitial()) {
    on<WatchUserChats>(_onWatchUserChats);
    on<WatchChatMessages>(_onWatchChatMessages);
    on<SendMessage>(_onSendMessage);
    on<CreateChat>(_onCreateChat);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<DeleteMessage>(_onDeleteMessage);
    on<DeleteChat>(_onDeleteChat);
    on<SearchMessages>(_onSearchMessages);
    on<GetChatByMatchId>(_onGetChatByMatchId);
    on<ClearCurrentChat>(_onClearCurrentChat);
    on<ClearChatError>(_onClearChatError);
  }

  /// Watch user's chats in real-time
  Future<void> _onWatchUserChats(
    WatchUserChats event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('🔍 CHAT_BLOC: Starting to watch user chats for userId: ${event.userId}');
      
      // Cancel existing subscription
      await _chatsSubscription?.cancel();
      print('🔍 CHAT_BLOC: Cancelled existing subscription');

      // Use emit.forEach to properly handle stream emissions
      await emit.forEach<List<ChatEntity>>(
        _getUserChatsUseCase(event.userId),
        onData: (chats) {
          print('🔍 CHAT_BLOC: Received ${chats.length} chats from stream');
          _currentChats = chats;
          return ChatsLoaded(
            chats: chats,
            currentChatId: _currentChatId,
          );
        },
        onError: (error, stackTrace) {
          print('🚨 CHAT_BLOC: Stream error: $error');
          return ChatError(message: 'Failed to load chats: $error');
        },
      );
    } catch (e) {
      print('🚨 CHAT_BLOC: Exception in _onWatchUserChats: $e');
      emit(ChatError(message: 'Failed to watch user chats: $e'));
    }
  }

  /// Watch messages for a specific chat in real-time
  Future<void> _onWatchChatMessages(
    WatchChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    try {
      _currentChatId = event.chatId;

      // Get chat details if we don't have them
      if (_currentChat?.id != event.chatId) {
        _currentChat = await _chatRepository.getChatById(event.chatId);
      }

      // Cancel existing messages subscription
      await _messagesSubscription?.cancel();

      // Use emit.forEach to properly handle stream emissions
      await emit.forEach<List<MessageEntity>>(
        _getChatMessagesUseCase(event.chatId, limit: event.limit),
        onData: (messages) {
          _currentMessages = messages;
          if (state is ChatCombinedState) {
            final currentState = state as ChatCombinedState;
            return currentState.copyWith(
              currentChatId: event.chatId,
              currentMessages: messages,
              currentChat: _currentChat,
              isLoadingMessages: false,
            );
          } else {
            return ChatCombinedState(
              chats: _currentChats,
              currentChatId: event.chatId,
              currentMessages: messages,
              currentChat: _currentChat,
            );
          }
        },
        onError: (error, stackTrace) {
          return ChatError(message: 'Failed to load messages: $error');
        },
      );
    } catch (e) {
      emit(ChatError(message: 'Failed to watch chat messages: $e'));
    }
  }

  /// Send a message
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Create temporary message for optimistic UI update
      final tempMessageId = _uuid.v4();
      final pendingMessage = MessageEntity(
        id: tempMessageId,
        chatId: event.chatId,
        senderId: event.senderId,
        senderName: event.senderName,
        content: event.content,
        type: event.type,
        timestamp: DateTime.now(),
        isRead: false,
        replyToMessageId: event.replyToMessageId,
        mediaUrl: event.mediaUrl,
        metadata: event.metadata,
      );

      emit(MessageSending(
        chatId: event.chatId,
        tempMessageId: tempMessageId,
        pendingMessage: pendingMessage,
      ));

      // Send the actual message
      final sentMessage = await _sendMessageUseCase(
        chatId: event.chatId,
        senderId: event.senderId,
        senderName: event.senderName,
        content: event.content,
        type: event.type,
        replyToMessageId: event.replyToMessageId,
        mediaUrl: event.mediaUrl,
        metadata: event.metadata,
      );

      emit(MessageSent(sentMessage));
    } catch (e) {
      emit(ChatError(message: 'Failed to send message: $e'));
    }
  }

  /// Create a new chat
  Future<void> _onCreateChat(
    CreateChat event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(const ChatLoading());

      final chat = await _createChatUseCase(
        matchId: event.matchId,
        user1Id: event.user1Id,
        user1Name: event.user1Name,
        user1Avatar: event.user1Avatar,
        user2Id: event.user2Id,
        user2Name: event.user2Name,
        user2Avatar: event.user2Avatar,
      );

      emit(ChatCreated(chat));
    } catch (e) {
      emit(ChatError(message: 'Failed to create chat: $e'));
    }
  }

  /// Mark messages as read
  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _markMessagesReadUseCase(
        chatId: event.chatId,
        userId: event.userId,
        messageIds: event.messageIds,
      );

      emit(MessagesMarkedAsRead(
        chatId: event.chatId,
        messageIds: event.messageIds,
      ));
    } catch (e) {
      emit(ChatError(message: 'Failed to mark messages as read: $e'));
    }
  }

  /// Delete a message
  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatRepository.deleteMessage(event.chatId, event.messageId);

      emit(MessageDeleted(
        chatId: event.chatId,
        messageId: event.messageId,
      ));
    } catch (e) {
      emit(ChatError(message: 'Failed to delete message: $e'));
    }
  }

  /// Delete a chat
  Future<void> _onDeleteChat(
    DeleteChat event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatRepository.deleteChat(event.chatId);

      // Clear current chat if it's the one being deleted
      if (_currentChatId == event.chatId) {
        _currentChatId = null;
        _currentMessages = [];
        _currentChat = null;
        await _messagesSubscription?.cancel();
      }

      emit(ChatDeleted(event.chatId));
    } catch (e) {
      emit(ChatError(message: 'Failed to delete chat: $e'));
    }
  }

  /// Search messages in a chat
  Future<void> _onSearchMessages(
    SearchMessages event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final searchStream = _chatRepository.searchMessages(
        chatId: event.chatId,
        query: event.query,
        limit: event.limit,
      );

      final results = await searchStream.first;

      emit(MessagesSearchResults(
        chatId: event.chatId,
        query: event.query,
        results: results,
      ));
    } catch (e) {
      emit(ChatError(message: 'Failed to search messages: $e'));
    }
  }

  /// Get chat by match ID
  Future<void> _onGetChatByMatchId(
    GetChatByMatchId event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final chat = await _chatRepository.getChatByMatchId(event.matchId);

      if (chat != null) {
        emit(ChatCreated(chat));
      } else {
        emit(const ChatError(message: 'Chat not found for this match'));
      }
    } catch (e) {
      emit(ChatError(message: 'Failed to get chat by match ID: $e'));
    }
  }

  /// Clear current chat
  Future<void> _onClearCurrentChat(
    ClearCurrentChat event,
    Emitter<ChatState> emit,
  ) async {
    _currentChatId = null;
    _currentMessages = [];
    _currentChat = null;
    await _messagesSubscription?.cancel();

    if (state is ChatCombinedState) {
      final currentState = state as ChatCombinedState;
      emit(currentState.copyWith(
        currentChatId: null,
        currentMessages: [],
        currentChat: null,
      ));
    }
  }

  /// Clear error state
  void _onClearChatError(
    ClearChatError event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatError) {
      emit(ChatCombinedState(
        chats: _currentChats,
        currentChatId: _currentChatId,
        currentMessages: _currentMessages,
        currentChat: _currentChat,
      ));
    }
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}