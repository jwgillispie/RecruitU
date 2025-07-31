import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

/// Use case for creating a new chat between matched users
class CreateChatUseCase {
  final ChatRepository _repository;

  CreateChatUseCase(this._repository);

  Future<ChatEntity> call({
    required String matchId,
    required String user1Id,
    required String user1Name,
    required String user1Avatar,
    required String user2Id,
    required String user2Name,
    required String user2Avatar,
  }) async {
    // Validate inputs
    if (matchId.isEmpty) {
      throw ArgumentError('Match ID cannot be empty');
    }
    
    if (user1Id.isEmpty || user2Id.isEmpty) {
      throw ArgumentError('User IDs cannot be empty');
    }
    
    if (user1Id == user2Id) {
      throw ArgumentError('Cannot create chat with the same user');
    }
    
    if (user1Name.isEmpty || user2Name.isEmpty) {
      throw ArgumentError('User names cannot be empty');
    }

    // Check if chat already exists for this match
    final existingChat = await _repository.getChatByMatchId(matchId);
    if (existingChat != null) {
      return existingChat;
    }

    return await _repository.createChat(
      matchId: matchId,
      user1Id: user1Id,
      user1Name: user1Name,
      user1Avatar: user1Avatar,
      user2Id: user2Id,
      user2Name: user2Name,
      user2Avatar: user2Avatar,
    );
  }
}