import '../entities/player_profile_entity.dart';
import '../entities/coach_profile_entity.dart';

/// Repository interface for profile operations
abstract class ProfileRepository {
  // Player Profile Operations
  
  /// Get player profile by user ID
  Future<PlayerProfileEntity?> getPlayerProfile(String userId);
  
  /// Create a new player profile
  Future<PlayerProfileEntity> createPlayerProfile(PlayerProfileEntity profile);
  
  /// Update player profile
  Future<PlayerProfileEntity> updatePlayerProfile(PlayerProfileEntity profile);
  
  /// Delete player profile
  Future<void> deletePlayerProfile(String userId);
  
  /// Check if player profile exists
  Future<bool> playerProfileExists(String userId);
  
  // Coach Profile Operations
  
  /// Get coach profile by user ID
  Future<CoachProfileEntity?> getCoachProfile(String userId);
  
  /// Create a new coach profile
  Future<CoachProfileEntity> createCoachProfile(CoachProfileEntity profile);
  
  /// Update coach profile
  Future<CoachProfileEntity> updateCoachProfile(CoachProfileEntity profile);
  
  /// Delete coach profile
  Future<void> deleteCoachProfile(String userId);
  
  /// Check if coach profile exists
  Future<bool> coachProfileExists(String userId);
  
  // Media Operations
  
  /// Upload profile image
  Future<String> uploadProfileImage(String userId, String imagePath);
  
  /// Upload video highlight
  Future<String> uploadVideoHighlight(String userId, String videoPath);
  
  /// Upload additional photo
  Future<String> uploadPhoto(String userId, String imagePath, String category);
  
  /// Delete media file
  Future<void> deleteMediaFile(String fileUrl);
  
  // Discovery Operations
  
  /// Get player profiles for discovery (for coaches)
  Future<List<PlayerProfileEntity>> getPlayerProfilesForDiscovery({
    required String coachUserId,
    Map<String, dynamic>? filters,
    int? limit,
    String? lastDocumentId,
  });
  
  /// Get coach profiles for discovery (for players)
  Future<List<CoachProfileEntity>> getCoachProfilesForDiscovery({
    required String playerUserId,
    Map<String, dynamic>? filters,
    int? limit,
    String? lastDocumentId,
  });
  
  /// Search profiles by text query
  Future<List<dynamic>> searchProfiles({
    required String query,
    required String userType, // 'player' or 'coach'
    Map<String, dynamic>? filters,
    int? limit,
  });
  
  // Analytics and Insights
  
  /// Get profile view count
  Future<int> getProfileViewCount(String userId);
  
  /// Increment profile view count
  Future<void> incrementProfileViewCount(String userId, String viewerUserId);
  
  /// Get profile completion suggestions
  Future<List<String>> getProfileCompletionSuggestions(String userId);
}