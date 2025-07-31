import '../../domain/entities/player_profile_entity.dart';
import '../../domain/entities/coach_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/firebase_profile_datasource.dart';
import '../models/player_profile_model.dart';
import '../models/coach_profile_model.dart';

/// Implementation of profile repository using Firebase
class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseProfileDataSource _dataSource;

  ProfileRepositoryImpl(this._dataSource);

  // Player Profile Operations

  @override
  Future<PlayerProfileEntity?> getPlayerProfile(String userId) async {
    try {
      return await _dataSource.getPlayerProfile(userId);
    } catch (e) {
      throw Exception('Repository: Failed to get player profile: $e');
    }
  }

  @override
  Future<PlayerProfileEntity> createPlayerProfile(PlayerProfileEntity profile) async {
    try {
      final model = PlayerProfileModel(
        id: profile.id,
        userId: profile.userId,
        displayName: profile.displayName,
        bio: profile.bio,
        profileImageUrl: profile.profileImageUrl,
        phoneNumber: profile.phoneNumber,
        location: profile.location,
        dateOfBirth: profile.dateOfBirth,
        nationality: profile.nationality,
        preferredFoot: profile.preferredFoot,
        height: profile.height,
        weight: profile.weight,
        primaryPosition: profile.primaryPosition,
        secondaryPositions: profile.secondaryPositions,
        currentDivision: profile.currentDivision,
        currentTeam: profile.currentTeam,
        currentSchool: profile.currentSchool,
        gpa: profile.gpa,
        satScore: profile.satScore,
        actScore: profile.actScore,
        graduationYear: profile.graduationYear,
        yearsPlaying: profile.yearsPlaying,
        achievements: profile.achievements,
        previousTeams: profile.previousTeams,
        videoHighlights: profile.videoHighlights,
        additionalPhotos: profile.additionalPhotos,
        achievementCertificates: profile.achievementCertificates,
        targetDivisions: profile.targetDivisions,
        targetRegions: profile.targetRegions,
        isPublic: profile.isPublic,
        isVerified: profile.isVerified,
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
        isProfileComplete: profile.isProfileComplete,
        completionPercentage: profile.completionPercentage,
      );

      return await _dataSource.createPlayerProfile(model.copyWithCompletion());
    } catch (e) {
      throw Exception('Repository: Failed to create player profile: $e');
    }
  }

  @override
  Future<PlayerProfileEntity> updatePlayerProfile(PlayerProfileEntity profile) async {
    try {
      final model = PlayerProfileModel(
        id: profile.id,
        userId: profile.userId,
        displayName: profile.displayName,
        bio: profile.bio,
        profileImageUrl: profile.profileImageUrl,
        phoneNumber: profile.phoneNumber,
        location: profile.location,
        dateOfBirth: profile.dateOfBirth,
        nationality: profile.nationality,
        preferredFoot: profile.preferredFoot,
        height: profile.height,
        weight: profile.weight,
        primaryPosition: profile.primaryPosition,
        secondaryPositions: profile.secondaryPositions,
        currentDivision: profile.currentDivision,
        currentTeam: profile.currentTeam,
        currentSchool: profile.currentSchool,
        gpa: profile.gpa,
        satScore: profile.satScore,
        actScore: profile.actScore,
        graduationYear: profile.graduationYear,
        yearsPlaying: profile.yearsPlaying,
        achievements: profile.achievements,
        previousTeams: profile.previousTeams,
        videoHighlights: profile.videoHighlights,
        additionalPhotos: profile.additionalPhotos,
        achievementCertificates: profile.achievementCertificates,
        targetDivisions: profile.targetDivisions,
        targetRegions: profile.targetRegions,
        isPublic: profile.isPublic,
        isVerified: profile.isVerified,
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
        isProfileComplete: profile.isProfileComplete,
        completionPercentage: profile.completionPercentage,
      );

      return await _dataSource.updatePlayerProfile(model.copyWithCompletion());
    } catch (e) {
      throw Exception('Repository: Failed to update player profile: $e');
    }
  }

  @override
  Future<void> deletePlayerProfile(String userId) async {
    try {
      await _dataSource.deletePlayerProfile(userId);
    } catch (e) {
      throw Exception('Repository: Failed to delete player profile: $e');
    }
  }

  @override
  Future<bool> playerProfileExists(String userId) async {
    try {
      return await _dataSource.playerProfileExists(userId);
    } catch (e) {
      throw Exception('Repository: Failed to check player profile existence: $e');
    }
  }

  // Coach Profile Operations

  @override
  Future<CoachProfileEntity?> getCoachProfile(String userId) async {
    try {
      return await _dataSource.getCoachProfile(userId);
    } catch (e) {
      throw Exception('Repository: Failed to get coach profile: $e');
    }
  }

  @override
  Future<CoachProfileEntity> createCoachProfile(CoachProfileEntity profile) async {
    try {
      final model = CoachProfileModel(
        id: profile.id,
        userId: profile.userId,
        displayName: profile.displayName,
        bio: profile.bio,
        profileImageUrl: profile.profileImageUrl,
        phoneNumber: profile.phoneNumber,
        email: profile.email,
        officialEmail: profile.officialEmail,
        location: profile.location,
        schoolName: profile.schoolName,
        programName: profile.programName,
        division: profile.division,
        conference: profile.conference,
        leagueName: profile.leagueName,
        teamName: profile.teamName,
        season: profile.season,
        coachingTitle: profile.coachingTitle,
        yearsCoaching: profile.yearsCoaching,
        yearsAtCurrentProgram: profile.yearsAtCurrentProgram,
        recruitingPositions: profile.recruitingPositions,
        targetRegions: profile.targetRegions,
        graduationYearTargets: profile.graduationYearTargets,
        recruitingPhilosophy: profile.recruitingPhilosophy,
        coachingPhilosophy: profile.coachingPhilosophy,
        programHistory: profile.programHistory,
        programAchievements: profile.programAchievements,
        facilitiesDescription: profile.facilitiesDescription,
        scholarshipInfo: profile.scholarshipInfo,
        websiteUrl: profile.websiteUrl,
        twitterHandle: profile.twitterHandle,
        instagramHandle: profile.instagramHandle,
        linkedinUrl: profile.linkedinUrl,
        programPhotos: profile.programPhotos,
        facilityPhotos: profile.facilityPhotos,
        teamVideos: profile.teamVideos,
        isVerified: profile.isVerified,
        isProgramOfficial: profile.isProgramOfficial,
        verificationDocuments: profile.verificationDocuments,
        isPublic: profile.isPublic,
        acceptingRecruits: profile.acceptingRecruits,
        allowDirectContact: profile.allowDirectContact,
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
        isProfileComplete: profile.isProfileComplete,
        completionPercentage: profile.completionPercentage,
      );

      return await _dataSource.createCoachProfile(model.copyWithCompletion());
    } catch (e) {
      throw Exception('Repository: Failed to create coach profile: $e');
    }
  }

  @override
  Future<CoachProfileEntity> updateCoachProfile(CoachProfileEntity profile) async {
    try {
      final model = CoachProfileModel(
        id: profile.id,
        userId: profile.userId,
        displayName: profile.displayName,
        bio: profile.bio,
        profileImageUrl: profile.profileImageUrl,
        phoneNumber: profile.phoneNumber,
        email: profile.email,
        officialEmail: profile.officialEmail,
        location: profile.location,
        schoolName: profile.schoolName,
        programName: profile.programName,
        division: profile.division,
        conference: profile.conference,
        leagueName: profile.leagueName,
        teamName: profile.teamName,
        season: profile.season,
        coachingTitle: profile.coachingTitle,
        yearsCoaching: profile.yearsCoaching,
        yearsAtCurrentProgram: profile.yearsAtCurrentProgram,
        recruitingPositions: profile.recruitingPositions,
        targetRegions: profile.targetRegions,
        graduationYearTargets: profile.graduationYearTargets,
        recruitingPhilosophy: profile.recruitingPhilosophy,
        coachingPhilosophy: profile.coachingPhilosophy,
        programHistory: profile.programHistory,
        programAchievements: profile.programAchievements,
        facilitiesDescription: profile.facilitiesDescription,
        scholarshipInfo: profile.scholarshipInfo,
        websiteUrl: profile.websiteUrl,
        twitterHandle: profile.twitterHandle,
        instagramHandle: profile.instagramHandle,
        linkedinUrl: profile.linkedinUrl,
        programPhotos: profile.programPhotos,
        facilityPhotos: profile.facilityPhotos,
        teamVideos: profile.teamVideos,
        isVerified: profile.isVerified,
        isProgramOfficial: profile.isProgramOfficial,
        verificationDocuments: profile.verificationDocuments,
        isPublic: profile.isPublic,
        acceptingRecruits: profile.acceptingRecruits,
        allowDirectContact: profile.allowDirectContact,
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
        isProfileComplete: profile.isProfileComplete,
        completionPercentage: profile.completionPercentage,
      );

      return await _dataSource.updateCoachProfile(model.copyWithCompletion());
    } catch (e) {
      throw Exception('Repository: Failed to update coach profile: $e');
    }
  }

  @override
  Future<void> deleteCoachProfile(String userId) async {
    try {
      await _dataSource.deleteCoachProfile(userId);
    } catch (e) {
      throw Exception('Repository: Failed to delete coach profile: $e');
    }
  }

  @override
  Future<bool> coachProfileExists(String userId) async {
    try {
      return await _dataSource.coachProfileExists(userId);
    } catch (e) {
      throw Exception('Repository: Failed to check coach profile existence: $e');
    }
  }

  // Media Operations

  @override
  Future<String> uploadProfileImage(String userId, String imagePath) async {
    try {
      return await _dataSource.uploadProfileImage(userId, imagePath);
    } catch (e) {
      throw Exception('Repository: Failed to upload profile image: $e');
    }
  }

  @override
  Future<String> uploadVideoHighlight(String userId, String videoPath) async {
    try {
      return await _dataSource.uploadVideoHighlight(userId, videoPath);
    } catch (e) {
      throw Exception('Repository: Failed to upload video highlight: $e');
    }
  }

  @override
  Future<String> uploadPhoto(String userId, String imagePath, String category) async {
    try {
      return await _dataSource.uploadPhoto(userId, imagePath, category);
    } catch (e) {
      throw Exception('Repository: Failed to upload photo: $e');
    }
  }

  @override
  Future<void> deleteMediaFile(String fileUrl) async {
    try {
      await _dataSource.deleteMediaFile(fileUrl);
    } catch (e) {
      throw Exception('Repository: Failed to delete media file: $e');
    }
  }

  // Discovery Operations

  @override
  Future<List<PlayerProfileEntity>> getPlayerProfilesForDiscovery({
    required String coachUserId,
    Map<String, dynamic>? filters,
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      final models = await _dataSource.getPlayerProfilesForDiscovery(
        coachUserId: coachUserId,
        filters: filters,
        limit: limit,
        lastDocumentId: lastDocumentId,
      );
      return models.cast<PlayerProfileEntity>();
    } catch (e) {
      throw Exception('Repository: Failed to get player profiles for discovery: $e');
    }
  }

  @override
  Future<List<CoachProfileEntity>> getCoachProfilesForDiscovery({
    required String playerUserId,
    Map<String, dynamic>? filters,
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      final models = await _dataSource.getCoachProfilesForDiscovery(
        playerUserId: playerUserId,
        filters: filters,
        limit: limit,
        lastDocumentId: lastDocumentId,
      );
      return models.cast<CoachProfileEntity>();
    } catch (e) {
      throw Exception('Repository: Failed to get coach profiles for discovery: $e');
    }
  }

  @override
  Future<List<dynamic>> searchProfiles({
    required String query,
    required String userType,
    Map<String, dynamic>? filters,
    int? limit,
  }) async {
    // Placeholder implementation
    return [];
  }

  @override
  Future<int> getProfileViewCount(String userId) async {
    // Placeholder implementation
    return 0;
  }

  @override
  Future<void> incrementProfileViewCount(String userId, String viewerUserId) async {
    // Placeholder implementation
  }

  @override
  Future<List<String>> getProfileCompletionSuggestions(String userId) async {
    // Placeholder implementation
    return [];
  }
}