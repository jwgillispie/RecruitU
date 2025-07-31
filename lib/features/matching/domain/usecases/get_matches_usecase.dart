import '../entities/match_entity.dart';
import '../repositories/matching_repository.dart';

class GetMatchesUseCase {
  final MatchingRepository _repository;

  GetMatchesUseCase(this._repository);

  Future<List<MatchEntity>> call(String userId) async {
    try {
      final matches = await _repository.getUserMatches(userId);
      // Sort matches by most recent activity
      matches.sort((a, b) {
        final aTime = a.lastMessageAt ?? a.matchedAt;
        final bTime = b.lastMessageAt ?? b.matchedAt;
        return bTime.compareTo(aTime);
      });
      return matches;
    } catch (e) {
      throw Exception('Failed to get matches: $e');
    }
  }
}

class WatchMatchesUseCase {
  final MatchingRepository _repository;

  WatchMatchesUseCase(this._repository);

  Stream<List<MatchEntity>> call(String userId) {
    return _repository.watchUserMatches(userId);
  }
}