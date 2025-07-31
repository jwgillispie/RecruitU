import '../entities/match_entity.dart';
import '../entities/swipe_action_entity.dart';

abstract class MatchingRepository {
  // Swipe actions
  Future<void> recordSwipeAction(SwipeActionEntity swipeAction);
  Future<bool> hasUserAlreadySwiped(String fromUserId, String toUserId);
  Future<SwipeActionEntity?> getSwipeAction(String fromUserId, String toUserId);
  
  // Match management
  Future<MatchEntity?> createMatch(String userId1, String userId2);
  Future<List<MatchEntity>> getUserMatches(String userId);
  Future<MatchEntity?> getMatch(String matchId);
  Future<void> updateMatch(MatchEntity match);
  Future<void> deleteMatch(String matchId);
  
  // Match checking
  Future<bool> checkForMatch(String userId1, String userId2);
  Future<List<String>> getMatchCandidates(String userId);
  
  // Real-time updates
  Stream<List<MatchEntity>> watchUserMatches(String userId);
  Stream<MatchEntity> watchMatch(String matchId);
}