import '../repositories/matching_repository.dart';

class UnmatchUseCase {
  final MatchingRepository _repository;

  UnmatchUseCase(this._repository);

  Future<void> call(String matchId) async {
    try {
      await _repository.deleteMatch(matchId);
    } catch (e) {
      throw Exception('Failed to unmatch: $e');
    }
  }
}