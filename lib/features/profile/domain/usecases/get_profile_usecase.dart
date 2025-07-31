import '../entities/player_profile_entity.dart';
import '../entities/coach_profile_entity.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/constants/app_constants.dart';

/// Use case for getting user profiles
class GetProfileUseCase {
  final ProfileRepository _repository;

  GetProfileUseCase(this._repository);

  /// Get player profile by user ID
  Future<PlayerProfileEntity?> getPlayerProfile(String userId) async {
    try {
      return await _repository.getPlayerProfile(userId);
    } catch (e) {
      throw Exception('Failed to get player profile: ${e.toString()}');
    }
  }

  /// Get coach profile by user ID  
  Future<CoachProfileEntity?> getCoachProfile(String userId) async {
    try {
      return await _repository.getCoachProfile(userId);
    } catch (e) {
      throw Exception('Failed to get coach profile: ${e.toString()}');
    }
  }

  /// Get profile by user ID and type
  Future<dynamic> getProfile(String userId, UserType userType) async {
    switch (userType) {
      case UserType.player:
        return await getPlayerProfile(userId);
      case UserType.coach:
        return await getCoachProfile(userId);
      default:
        throw Exception('Unsupported user type: $userType');
    }
  }

  /// Check if profile exists for user
  Future<bool> profileExists(String userId, UserType userType) async {
    try {
      switch (userType) {
        case UserType.player:
          return await _repository.playerProfileExists(userId);
        case UserType.coach:
          return await _repository.coachProfileExists(userId);
        default:
          return false;
      }
    } catch (e) {
      throw Exception('Failed to check profile existence: ${e.toString()}');
    }
  }
}