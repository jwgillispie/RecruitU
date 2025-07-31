import '../repositories/chat_repository.dart';

/// Use case for marking messages as read
class MarkMessagesReadUseCase {
  final ChatRepository _repository;

  MarkMessagesReadUseCase(this._repository);

  Future<void> call({
    required String chatId,
    required String userId,
    required List<String> messageIds,
  }) async {
    if (chatId.isEmpty) {
      throw ArgumentError('Chat ID cannot be empty');
    }
    
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    
    if (messageIds.isEmpty) {
      return; // Nothing to mark as read
    }

    await _repository.markMessagesAsRead(
      chatId: chatId,
      userId: userId,
      messageIds: messageIds,
    );
  }
}