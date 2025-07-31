import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

/// Use case for getting messages from a chat
class GetChatMessagesUseCase {
  final ChatRepository _repository;

  GetChatMessagesUseCase(this._repository);

  Stream<List<MessageEntity>> call(String chatId, {int limit = 50}) {
    if (chatId.isEmpty) {
      throw ArgumentError('Chat ID cannot be empty');
    }

    if (limit <= 0) {
      throw ArgumentError('Limit must be greater than 0');
    }

    return _repository.getChatMessages(chatId, limit: limit);
  }
}