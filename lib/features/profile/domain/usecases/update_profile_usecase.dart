import '../entities/player_profile_entity.dart';
import '../entities/coach_profile_entity.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/constants/app_constants.dart';

/// Use case for updating user profiles
class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  /// Update player profile
  Future<PlayerProfileEntity> updatePlayerProfile(PlayerProfileEntity profile) async {
    try {
      // Calculate completion percentage
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
        completionPercentage: profile.calculateCompletionPercentage(),
        isProfileComplete: profile.calculateCompletionPercentage() >= 70.0,
      );

      return await _repository.updatePlayerProfile(updatedProfile);
    } catch (e) {
      throw Exception('Failed to update player profile: ${e.toString()}');
    }
  }

  /// Update coach profile
  Future<CoachProfileEntity> updateCoachProfile(CoachProfileEntity profile) async {
    try {
      // Calculate completion percentage
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
        completionPercentage: profile.calculateCompletionPercentage(),
        isProfileComplete: profile.calculateCompletionPercentage() >= 70.0,
      );

      return await _repository.updateCoachProfile(updatedProfile);
    } catch (e) {
      throw Exception('Failed to update coach profile: ${e.toString()}');
    }
  }

  /// Create new player profile
  Future<PlayerProfileEntity> createPlayerProfile({
    required String userId,
    required String displayName,
    required SoccerPosition primaryPosition,
  }) async {
    try {
      final now = DateTime.now();
      final profile = PlayerProfileEntity(
        id: '', // Will be set by repository
        userId: userId,
        displayName: displayName,
        primaryPosition: primaryPosition,
        createdAt: now,
        updatedAt: now,
      );

      return await _repository.createPlayerProfile(profile);
    } catch (e) {
      throw Exception('Failed to create player profile: ${e.toString()}');
    }
  }

  /// Create new coach profile
  Future<CoachProfileEntity> createCoachProfile({
    required String userId,
    required String displayName,
    required String schoolName,
    required String coachingTitle,
  }) async {
    try {
      final now = DateTime.now();
      final profile = CoachProfileEntity(
        id: '', // Will be set by repository
        userId: userId,
        displayName: displayName,
        schoolName: schoolName,
        coachingTitle: coachingTitle,
        createdAt: now,
        updatedAt: now,
      );

      return await _repository.createCoachProfile(profile);
    } catch (e) {
      throw Exception('Failed to create coach profile: ${e.toString()}');
    }
  }

  /// Update profile image
  Future<String> updateProfileImage(String userId, String imagePath) async {
    try {
      return await _repository.uploadProfileImage(userId, imagePath);
    } catch (e) {
      throw Exception('Failed to update profile image: ${e.toString()}');
    }
  }

  /// Add video highlight
  Future<String> addVideoHighlight(String userId, String videoPath) async {
    try {
      return await _repository.uploadVideoHighlight(userId, videoPath);
    } catch (e) {
      throw Exception('Failed to add video highlight: ${e.toString()}');
    }
  }

  /// Delete profile
  Future<void> deleteProfile(String userId, UserType userType) async {
    try {
      switch (userType) {
        case UserType.player:
          await _repository.deletePlayerProfile(userId);
          break;
        case UserType.coach:
          await _repository.deleteCoachProfile(userId);
          break;
        default:
          throw Exception('Unsupported user type: $userType');
      }
    } catch (e) {
      throw Exception('Failed to delete profile: ${e.toString()}');
    }
  }
}