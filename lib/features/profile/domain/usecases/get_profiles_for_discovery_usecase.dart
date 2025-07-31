import '../entities/player_profile_entity.dart';
import '../entities/coach_profile_entity.dart';
import '../repositories/profile_repository.dart';

/// Use case for getting profiles for discovery based on user type
class GetProfilesForDiscoveryUseCase {
  final ProfileRepository _profileRepository;

  const GetProfilesForDiscoveryUseCase(this._profileRepository);

  /// Get player profiles for discovery (for coaches)
  Future<List<PlayerProfileEntity>> getPlayerProfiles({
    required String coachUserId,
    Map<String, dynamic>? filters,
    int? limit,
    String? lastDocumentId,
  }) async {
    return await _profileRepository.getPlayerProfilesForDiscovery(
      coachUserId: coachUserId,
      filters: filters,
      limit: limit,
      lastDocumentId: lastDocumentId,
    );
  }

  /// Get coach profiles for discovery (for players)
  Future<List<CoachProfileEntity>> getCoachProfiles({
    required String playerUserId,
    Map<String, dynamic>? filters,
    int? limit,
    String? lastDocumentId,
  }) async {
    return await _profileRepository.getCoachProfilesForDiscovery(
      playerUserId: playerUserId,
      filters: filters,
      limit: limit,
      lastDocumentId: lastDocumentId,
    );
  }
}