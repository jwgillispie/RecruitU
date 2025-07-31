import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/player_profile_entity.dart';
import '../../../../core/constants/app_constants.dart';

/// Data model for player profile with Firestore serialization
class PlayerProfileModel extends PlayerProfileEntity {
  const PlayerProfileModel({
    required super.id,
    required super.userId,
    required super.displayName,
    super.bio,
    super.profileImageUrl,
    super.phoneNumber,
    super.location,
    super.dateOfBirth,
    super.nationality,
    super.preferredFoot,
    super.height,
    super.weight,
    required super.primaryPosition,
    super.secondaryPositions,
    super.currentDivision,
    super.currentTeam,
    super.currentSchool,
    super.gpa,
    super.satScore,
    super.actScore,
    super.graduationYear,
    super.yearsPlaying,
    super.achievements,
    super.previousTeams,
    super.videoHighlights,
    super.additionalPhotos,
    super.achievementCertificates,
    super.targetDivisions,
    super.targetRegions,
    super.isPublic,
    super.isVerified,
    required super.createdAt,
    required super.updatedAt,
    super.isProfileComplete,
    super.completionPercentage,
  });

  /// Create from Firestore document
  factory PlayerProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PlayerProfileModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      bio: data['bio'],
      profileImageUrl: data['profileImageUrl'],
      phoneNumber: data['phoneNumber'],
      location: data['location'],
      dateOfBirth: data['dateOfBirth']?.toDate(),
      nationality: data['nationality'],
      preferredFoot: data['preferredFoot'],
      height: data['height']?.toDouble(),
      weight: data['weight']?.toDouble(),
      primaryPosition: _positionFromString(data['primaryPosition']) ?? SoccerPosition.st,
      secondaryPositions: _positionsFromList(data['secondaryPositions'] ?? []),
      currentDivision: _divisionFromString(data['currentDivision']),
      currentTeam: data['currentTeam'],
      currentSchool: data['currentSchool'],
      gpa: data['gpa']?.toDouble(),
      satScore: data['satScore']?.toInt(),
      actScore: data['actScore']?.toInt(),
      graduationYear: data['graduationYear'],
      yearsPlaying: data['yearsPlaying']?.toInt(),
      achievements: List<String>.from(data['achievements'] ?? []),
      previousTeams: List<String>.from(data['previousTeams'] ?? []),
      videoHighlights: List<String>.from(data['videoHighlights'] ?? []),
      additionalPhotos: List<String>.from(data['additionalPhotos'] ?? []),
      achievementCertificates: List<String>.from(data['achievementCertificates'] ?? []),
      targetDivisions: _divisionsFromList(data['targetDivisions'] ?? []),
      targetRegions: List<String>.from(data['targetRegions'] ?? []),
      isPublic: data['isPublic'] ?? true,
      isVerified: data['isVerified'] ?? false,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
      isProfileComplete: data['isProfileComplete'] ?? false,
      completionPercentage: data['completionPercentage']?.toDouble() ?? 0.0,
    );
  }

  /// Create from form data (for profile completion)
  factory PlayerProfileModel.fromFormData({
    required String userId,
    required String displayName,
    required Map<String, dynamic> formData,
  }) {
    final now = DateTime.now();
    
    // Parse additional photos list
    final additionalPhotosData = formData['additionalPhotos'];
    List<String>? additionalPhotos;
    if (additionalPhotosData is List) {
      additionalPhotos = additionalPhotosData.cast<String>();
    }
    
    return PlayerProfileModel(
      id: '', // Will be set by Firestore
      userId: userId,
      displayName: displayName,
      bio: formData['bio'],
      profileImageUrl: formData['profilePhotoUrl'],
      phoneNumber: formData['phoneNumber'],
      location: formData['location'],
      currentSchool: formData['currentSchool'],
      gpa: formData['gpa'] != null ? double.tryParse(formData['gpa']) : null,
      graduationYear: formData['graduationYear'],
      primaryPosition: formData['primaryPosition'] ?? SoccerPosition.st,
      secondaryPositions: const [], // Initialize empty list
      achievements: const [], // Initialize empty list
      previousTeams: const [], // Initialize empty list
      videoHighlights: const [], // Initialize empty list
      additionalPhotos: additionalPhotos ?? [],
      achievementCertificates: const [], // Initialize empty list
      targetDivisions: const [], // Initialize empty list
      targetRegions: const [], // Initialize empty list
      isPublic: true, // Default to public for discovery
      createdAt: now,
      updatedAt: now,
      isProfileComplete: false,
      completionPercentage: 0.0,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'displayName': displayName,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'location': location,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'nationality': nationality,
      'preferredFoot': preferredFoot,
      'height': height,
      'weight': weight,
      'primaryPosition': primaryPosition.name,
      'secondaryPositions': secondaryPositions.map((p) => p.name).toList(),
      'currentDivision': currentDivision?.name,
      'currentTeam': currentTeam,
      'currentSchool': currentSchool,
      'gpa': gpa,
      'satScore': satScore,
      'actScore': actScore,
      'graduationYear': graduationYear,
      'yearsPlaying': yearsPlaying,
      'achievements': achievements,
      'previousTeams': previousTeams,
      'videoHighlights': videoHighlights,
      'additionalPhotos': additionalPhotos,
      'achievementCertificates': achievementCertificates,
      'targetDivisions': targetDivisions.map((d) => d.name).toList(),
      'targetRegions': targetRegions,
      'isPublic': isPublic,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isProfileComplete': isProfileComplete,
      'completionPercentage': completionPercentage,
    };
  }

  /// Helper methods for enum conversion
  static SoccerPosition? _positionFromString(String? positionName) {
    if (positionName == null) return null;
    try {
      return SoccerPosition.values.firstWhere((p) => p.name == positionName);
    } catch (e) {
      return null;
    }
  }

  static List<SoccerPosition> _positionsFromList(List<dynamic> positionNames) {
    return positionNames
        .map((name) => _positionFromString(name.toString()))
        .where((position) => position != null)
        .cast<SoccerPosition>()
        .toList();
  }

  static DivisionLevel? _divisionFromString(String? divisionName) {
    if (divisionName == null) return null;
    try {
      return DivisionLevel.values.firstWhere((d) => d.name == divisionName);
    } catch (e) {
      return null;
    }
  }

  static List<DivisionLevel> _divisionsFromList(List<dynamic> divisionNames) {
    return divisionNames
        .map((name) => _divisionFromString(name.toString()))
        .where((division) => division != null)
        .cast<DivisionLevel>()
        .toList();
  }

  /// Copy with updated completion data
  PlayerProfileModel copyWithCompletion() {
    final completionPercentage = calculateCompletionPercentage();
    
    return PlayerProfileModel(
      id: id,
      userId: userId,
      displayName: displayName,
      bio: bio,
      profileImageUrl: profileImageUrl,
      phoneNumber: phoneNumber,
      location: location,
      dateOfBirth: dateOfBirth,
      nationality: nationality,
      preferredFoot: preferredFoot,
      height: height,
      weight: weight,
      primaryPosition: primaryPosition,
      secondaryPositions: secondaryPositions,
      currentDivision: currentDivision,
      currentTeam: currentTeam,
      currentSchool: currentSchool,
      gpa: gpa,
      satScore: satScore,
      actScore: actScore,
      graduationYear: graduationYear,
      yearsPlaying: yearsPlaying,
      achievements: achievements,
      previousTeams: previousTeams,
      videoHighlights: videoHighlights,
      additionalPhotos: additionalPhotos,
      achievementCertificates: achievementCertificates,
      targetDivisions: targetDivisions,
      targetRegions: targetRegions,
      isPublic: isPublic,
      isVerified: isVerified,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isProfileComplete: completionPercentage >= 70.0,
      completionPercentage: completionPercentage,
    );
  }
}