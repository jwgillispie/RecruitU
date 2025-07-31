import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

/// Use case for getting all chats for a user
class GetUserChatsUseCase {
  final ChatRepository _repository;

  GetUserChatsUseCase(this._repository);

  Stream<List<ChatEntity>> call(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    print('🔍 GET_USER_CHATS_USECASE: Getting chats for userId: $userId');
    
    return _repository.getUserChats(userId).handleError((error) {
      print('🚨 GET_USER_CHATS_USECASE: Stream error: $error');
      throw error;
    });
  }
}