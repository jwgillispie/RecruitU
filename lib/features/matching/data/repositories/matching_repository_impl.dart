import '../../domain/entities/match_entity.dart';
import '../../domain/entities/swipe_action_entity.dart';
import '../../domain/repositories/matching_repository.dart';
import '../datasources/firebase_matching_datasource.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/domain/entities/player_profile_entity.dart';
import '../../../profile/domain/entities/coach_profile_entity.dart';

class MatchingRepositoryImpl implements MatchingRepository {
  final FirebaseMatchingDatasource _datasource;
  final ProfileRepository _profileRepository;

  MatchingRepositoryImpl(this._datasource, this._profileRepository);

  @override
  Future<void> recordSwipeAction(SwipeActionEntity swipeAction) async {
    await _datasource.recordSwipeAction(swipeAction);
  }

  @override
  Future<bool> hasUserAlreadySwiped(String fromUserId, String toUserId) async {
    return await _datasource.hasUserAlreadySwiped(fromUserId, toUserId);
  }

  @override
  Future<SwipeActionEntity?> getSwipeAction(String fromUserId, String toUserId) async {
    return await _datasource.getSwipeAction(fromUserId, toUserId);
  }

  @override
  Future<MatchEntity?> createMatch(String userId1, String userId2) async {
    try {
      // Get user profiles to get names and profile images
      // Try to get both as player and coach profiles
      final user1PlayerProfile = await _profileRepository.getPlayerProfile(userId1);
      final user1CoachProfile = await _profileRepository.getCoachProfile(userId1);
      final user2PlayerProfile = await _profileRepository.getPlayerProfile(userId2);
      final user2CoachProfile = await _profileRepository.getCoachProfile(userId2);

      final user1Profile = user1PlayerProfile ?? user1CoachProfile;
      final user2Profile = user2PlayerProfile ?? user2CoachProfile;

      if (user1Profile == null || user2Profile == null) {
        throw Exception('User profiles not found');
      }

      String user1Name = '';
      String user2Name = '';
      String? user1Image;
      String? user2Image;

      if (user1Profile is PlayerProfileEntity) {
        user1Name = user1Profile.displayName;
        user1Image = user1Profile.profileImageUrl;
      } else if (user1Profile is CoachProfileEntity) {
        user1Name = user1Profile.displayName;
        user1Image = user1Profile.profileImageUrl;
      }

      if (user2Profile is PlayerProfileEntity) {
        user2Name = user2Profile.displayName;
        user2Image = user2Profile.profileImageUrl;
      } else if (user2Profile is CoachProfileEntity) {
        user2Name = user2Profile.displayName;
        user2Image = user2Profile.profileImageUrl;
      }

      return await _datasource.createMatch(
        userId1,
        userId2,
        user1Name,
        user2Name,
        user1Image,
        user2Image,
      );
    } catch (e) {
      throw Exception('Failed to create match: $e');
    }
  }

  @override
  Future<List<MatchEntity>> getUserMatches(String userId) async {
    return await _datasource.getUserMatches(userId);
  }

  @override
  Future<MatchEntity?> getMatch(String matchId) async {
    return await _datasource.getMatch(matchId);
  }

  @override
  Future<void> updateMatch(MatchEntity match) async {
    await _datasource.updateMatch(match);
  }

  @override
  Future<void> deleteMatch(String matchId) async {
    await _datasource.deleteMatch(matchId);
  }

  @override
  Future<bool> checkForMatch(String userId1, String userId2) async {
    return await _datasource.checkForMatch(userId1, userId2);
  }

  @override
  Future<List<String>> getMatchCandidates(String userId) async {
    return await _datasource.getMatchCandidates(userId);
  }

  @override
  Stream<List<MatchEntity>> watchUserMatches(String userId) {
    return _datasource.watchUserMatches(userId);
  }

  @override
  Stream<MatchEntity> watchMatch(String matchId) {
    return _datasource.watchMatch(matchId);
  }
}