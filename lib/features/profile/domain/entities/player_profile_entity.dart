import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

/// Player profile entity representing a soccer player's complete profile
class PlayerProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String displayName;
  final String? bio;
  final String? profileImageUrl;
  
  // Personal Information
  final String? phoneNumber;
  final String? location;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? preferredFoot;
  
  // Physical Attributes
  final double? height; // in cm
  final double? weight; // in kg
  
  // Playing Information
  final SoccerPosition primaryPosition;
  final List<SoccerPosition> secondaryPositions;
  final DivisionLevel? currentDivision;
  final String? currentTeam;
  final String? currentSchool;
  
  // Academic Information
  final double? gpa;
  final int? satScore;
  final int? actScore;
  final String? graduationYear;
  
  // Playing Experience
  final int? yearsPlaying;
  final List<String> achievements;
  final List<String> previousTeams;
  
  // Media
  final List<String> videoHighlights;
  final List<String> additionalPhotos;
  final List<String> achievementCertificates;
  
  // Preferences
  final List<DivisionLevel> targetDivisions;
  final List<String> targetRegions;
  final bool isPublic;
  final bool isVerified;
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isProfileComplete;
  final double completionPercentage;

  const PlayerProfileEntity({
    required this.id,
    required this.userId,
    required this.displayName,
    this.bio,
    this.profileImageUrl,
    this.phoneNumber,
    this.location,
    this.dateOfBirth,
    this.nationality,
    this.preferredFoot,
    this.height,
    this.weight,
    required this.primaryPosition,
    this.secondaryPositions = const [],
    this.currentDivision,
    this.currentTeam,
    this.currentSchool,
    this.gpa,
    this.satScore,
    this.actScore,
    this.graduationYear,
    this.yearsPlaying,
    this.achievements = const [],
    this.previousTeams = const [],
    this.videoHighlights = const [],
    this.additionalPhotos = const [],
    this.achievementCertificates = const [],
    this.targetDivisions = const [],
    this.targetRegions = const [],
    this.isPublic = true,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.isProfileComplete = false,
    this.completionPercentage = 0.0,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        displayName,
        bio,
        profileImageUrl,
        phoneNumber,
        location,
        dateOfBirth,
        nationality,
        preferredFoot,
        height,
        weight,
        primaryPosition,
        secondaryPositions,
        currentDivision,
        currentTeam,
        currentSchool,
        gpa,
        satScore,
        actScore,
        graduationYear,
        yearsPlaying,
        achievements,
        previousTeams,
        videoHighlights,
        additionalPhotos,
        achievementCertificates,
        targetDivisions,
        targetRegions,
        isPublic,
        isVerified,
        createdAt,
        updatedAt,
        isProfileComplete,
        completionPercentage,
      ];

  PlayerProfileEntity copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? bio,
    String? profileImageUrl,
    String? phoneNumber,
    String? location,
    DateTime? dateOfBirth,
    String? nationality,
    String? preferredFoot,
    double? height,
    double? weight,
    SoccerPosition? primaryPosition,
    List<SoccerPosition>? secondaryPositions,
    DivisionLevel? currentDivision,
    String? currentTeam,
    String? currentSchool,
    double? gpa,
    int? satScore,
    int? actScore,
    String? graduationYear,
    int? yearsPlaying,
    List<String>? achievements,
    List<String>? previousTeams,
    List<String>? videoHighlights,
    List<String>? additionalPhotos,
    List<String>? achievementCertificates,
    List<DivisionLevel>? targetDivisions,
    List<String>? targetRegions,
    bool? isPublic,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isProfileComplete,
    double? completionPercentage,
  }) {
    return PlayerProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      preferredFoot: preferredFoot ?? this.preferredFoot,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      primaryPosition: primaryPosition ?? this.primaryPosition,
      secondaryPositions: secondaryPositions ?? this.secondaryPositions,
      currentDivision: currentDivision ?? this.currentDivision,
      currentTeam: currentTeam ?? this.currentTeam,
      currentSchool: currentSchool ?? this.currentSchool,
      gpa: gpa ?? this.gpa,
      satScore: satScore ?? this.satScore,
      actScore: actScore ?? this.actScore,
      graduationYear: graduationYear ?? this.graduationYear,
      yearsPlaying: yearsPlaying ?? this.yearsPlaying,
      achievements: achievements ?? this.achievements,
      previousTeams: previousTeams ?? this.previousTeams,
      videoHighlights: videoHighlights ?? this.videoHighlights,
      additionalPhotos: additionalPhotos ?? this.additionalPhotos,
      achievementCertificates: achievementCertificates ?? this.achievementCertificates,
      targetDivisions: targetDivisions ?? this.targetDivisions,
      targetRegions: targetRegions ?? this.targetRegions,
      isPublic: isPublic ?? this.isPublic,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }

  /// Calculate profile completion percentage based on filled fields
  double calculateCompletionPercentage() {
    int totalFields = 20; // Total number of key fields
    int filledFields = 0;

    // Required fields
    if (displayName.isNotEmpty) filledFields++;
    if (bio != null && bio!.isNotEmpty) filledFields++;
    if (profileImageUrl != null) filledFields++;
    if (phoneNumber != null) filledFields++;
    if (location != null) filledFields++;
    if (dateOfBirth != null) filledFields++;
    if (preferredFoot != null) filledFields++;
    if (height != null) filledFields++;
    if (weight != null) filledFields++;
    if (currentTeam != null) filledFields++;
    if (currentSchool != null) filledFields++;
    if (gpa != null) filledFields++;
    if (graduationYear != null) filledFields++;
    if (yearsPlaying != null) filledFields++;
    if (achievements.isNotEmpty) filledFields++;
    if (previousTeams.isNotEmpty) filledFields++;
    if (videoHighlights.isNotEmpty) filledFields++;
    if (targetDivisions.isNotEmpty) filledFields++;
    if (targetRegions.isNotEmpty) filledFields++;
    filledFields++; // primaryPosition is always required

    return (filledFields / totalFields) * 100;
  }

  /// Check if profile meets minimum completion requirements
  bool get isMinimumComplete {
    return displayName.isNotEmpty &&
           bio != null &&
           profileImageUrl != null &&
           phoneNumber != null &&
           location != null &&
           completionPercentage >= 70.0;
  }
}