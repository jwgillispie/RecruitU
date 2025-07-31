import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

/// Use case for sending a message in a chat
class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<MessageEntity> call({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    String? mediaUrl,
    Map<String, dynamic>? metadata,
  }) async {
    // Validate input
    if (chatId.isEmpty) {
      throw ArgumentError('Chat ID cannot be empty');
    }
    
    if (senderId.isEmpty) {
      throw ArgumentError('Sender ID cannot be empty');
    }
    
    if (senderName.isEmpty) {
      throw ArgumentError('Sender name cannot be empty');
    }
    
    if (content.trim().isEmpty && type == MessageType.text) {
      throw ArgumentError('Message content cannot be empty for text messages');
    }

    // For media messages, ensure mediaUrl is provided
    if (type.hasMedia && (mediaUrl == null || mediaUrl.isEmpty)) {
      throw ArgumentError('Media URL is required for ${type.displayName} messages');
    }

    return await _repository.sendMessage(
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      content: content.trim(),
      type: type,
      replyToMessageId: replyToMessageId,
      mediaUrl: mediaUrl,
      metadata: metadata,
    );
  }
}