import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

/// Coach profile entity representing a coach's complete program profile
class CoachProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String displayName;
  final String? bio;
  final String? profileImageUrl;
  
  // Contact Information
  final String? phoneNumber;
  final String? email;
  final String? officialEmail;
  final String? location;
  
  // Program Information
  final String? schoolName;
  final String? programName;
  final DivisionLevel? division;
  final String? conference;
  final String? leagueName;
  
  // Team Details
  final String? teamName;
  final String? season;
  final String? coachingTitle; // Head Coach, Assistant Coach, etc.
  final int? yearsCoaching;
  final int? yearsAtCurrentProgram;
  
  // Recruiting Information
  final List<SoccerPosition> recruitingPositions;
  final List<String> targetRegions;
  final String? graduationYearTargets; // "2025, 2026"
  final String? recruitingPhilosophy;
  
  // Program Details
  final String? coachingPhilosophy;
  final String? programHistory;
  final List<String> programAchievements;
  final String? facilitiesDescription;
  final String? scholarshipInfo;
  
  // Social Media & Contact
  final String? websiteUrl;
  final String? twitterHandle;
  final String? instagramHandle;
  final String? linkedinUrl;
  
  // Media
  final List<String> programPhotos;
  final List<String> facilityPhotos;
  final List<String> teamVideos;
  
  // Verification
  final bool isVerified;
  final bool isProgramOfficial; // Official program representative
  final String? verificationDocuments;
  
  // Privacy & Settings
  final bool isPublic;
  final bool acceptingRecruits;
  final bool allowDirectContact;
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isProfileComplete;
  final double completionPercentage;

  const CoachProfileEntity({
    required this.id,
    required this.userId,
    required this.displayName,
    this.bio,
    this.profileImageUrl,
    this.phoneNumber,
    this.email,
    this.officialEmail,
    this.location,
    this.schoolName,
    this.programName,
    this.division,
    this.conference,
    this.leagueName,
    this.teamName,
    this.season,
    this.coachingTitle,
    this.yearsCoaching,
    this.yearsAtCurrentProgram,
    this.recruitingPositions = const [],
    this.targetRegions = const [],
    this.graduationYearTargets,
    this.recruitingPhilosophy,
    this.coachingPhilosophy,
    this.programHistory,
    this.programAchievements = const [],
    this.facilitiesDescription,
    this.scholarshipInfo,
    this.websiteUrl,
    this.twitterHandle,
    this.instagramHandle,
    this.linkedinUrl,
    this.programPhotos = const [],
    this.facilityPhotos = const [],
    this.teamVideos = const [],
    this.isVerified = false,
    this.isProgramOfficial = false,
    this.verificationDocuments,
    this.isPublic = true,
    this.acceptingRecruits = true,
    this.allowDirectContact = true,
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
        email,
        officialEmail,
        location,
        schoolName,
        programName,
        division,
        conference,
        leagueName,
        teamName,
        season,
        coachingTitle,
        yearsCoaching,
        yearsAtCurrentProgram,
        recruitingPositions,
        targetRegions,
        graduationYearTargets,
        recruitingPhilosophy,
        coachingPhilosophy,
        programHistory,
        programAchievements,
        facilitiesDescription,
        scholarshipInfo,
        websiteUrl,
        twitterHandle,
        instagramHandle,
        linkedinUrl,
        programPhotos,
        facilityPhotos,
        teamVideos,
        isVerified,
        isProgramOfficial,
        verificationDocuments,
        isPublic,
        acceptingRecruits,
        allowDirectContact,
        createdAt,
        updatedAt,
        isProfileComplete,
        completionPercentage,
      ];

  CoachProfileEntity copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? bio,
    String? profileImageUrl,
    String? phoneNumber,
    String? email,
    String? officialEmail,
    String? location,
    String? schoolName,
    String? programName,
    DivisionLevel? division,
    String? conference,
    String? leagueName,
    String? teamName,
    String? season,
    String? coachingTitle,
    int? yearsCoaching,
    int? yearsAtCurrentProgram,
    List<SoccerPosition>? recruitingPositions,
    List<String>? targetRegions,
    String? graduationYearTargets,
    String? recruitingPhilosophy,
    String? coachingPhilosophy,
    String? programHistory,
    List<String>? programAchievements,
    String? facilitiesDescription,
    String? scholarshipInfo,
    String? websiteUrl,
    String? twitterHandle,
    String? instagramHandle,
    String? linkedinUrl,
    List<String>? programPhotos,
    List<String>? facilityPhotos,
    List<String>? teamVideos,
    bool? isVerified,
    bool? isProgramOfficial,
    String? verificationDocuments,
    bool? isPublic,
    bool? acceptingRecruits,
    bool? allowDirectContact,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isProfileComplete,
    double? completionPercentage,
  }) {
    return CoachProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      officialEmail: officialEmail ?? this.officialEmail,
      location: location ?? this.location,
      schoolName: schoolName ?? this.schoolName,
      programName: programName ?? this.programName,
      division: division ?? this.division,
      conference: conference ?? this.conference,
      leagueName: leagueName ?? this.leagueName,
      teamName: teamName ?? this.teamName,
      season: season ?? this.season,
      coachingTitle: coachingTitle ?? this.coachingTitle,
      yearsCoaching: yearsCoaching ?? this.yearsCoaching,
      yearsAtCurrentProgram: yearsAtCurrentProgram ?? this.yearsAtCurrentProgram,
      recruitingPositions: recruitingPositions ?? this.recruitingPositions,
      targetRegions: targetRegions ?? this.targetRegions,
      graduationYearTargets: graduationYearTargets ?? this.graduationYearTargets,
      recruitingPhilosophy: recruitingPhilosophy ?? this.recruitingPhilosophy,
      coachingPhilosophy: coachingPhilosophy ?? this.coachingPhilosophy,
      programHistory: programHistory ?? this.programHistory,
      programAchievements: programAchievements ?? this.programAchievements,
      facilitiesDescription: facilitiesDescription ?? this.facilitiesDescription,
      scholarshipInfo: scholarshipInfo ?? this.scholarshipInfo,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      twitterHandle: twitterHandle ?? this.twitterHandle,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      programPhotos: programPhotos ?? this.programPhotos,
      facilityPhotos: facilityPhotos ?? this.facilityPhotos,
      teamVideos: teamVideos ?? this.teamVideos,
      isVerified: isVerified ?? this.isVerified,
      isProgramOfficial: isProgramOfficial ?? this.isProgramOfficial,
      verificationDocuments: verificationDocuments ?? this.verificationDocuments,
      isPublic: isPublic ?? this.isPublic,
      acceptingRecruits: acceptingRecruits ?? this.acceptingRecruits,
      allowDirectContact: allowDirectContact ?? this.allowDirectContact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }

  /// Calculate profile completion percentage based on filled fields
  double calculateCompletionPercentage() {
    int totalFields = 18; // Total number of key fields
    int filledFields = 0;

    // Required fields
    if (displayName.isNotEmpty) filledFields++;
    if (bio != null && bio!.isNotEmpty) filledFields++;
    if (profileImageUrl != null) filledFields++;
    if (phoneNumber != null) filledFields++;
    if (email != null) filledFields++;
    if (location != null) filledFields++;
    if (schoolName != null) filledFields++;
    if (programName != null) filledFields++;
    if (division != null) filledFields++;
    if (coachingTitle != null) filledFields++;
    if (yearsCoaching != null) filledFields++;
    if (recruitingPositions.isNotEmpty) filledFields++;
    if (targetRegions.isNotEmpty) filledFields++;
    if (coachingPhilosophy != null) filledFields++;
    if (recruitingPhilosophy != null) filledFields++;
    if (programAchievements.isNotEmpty) filledFields++;
    if (scholarshipInfo != null) filledFields++;
    if (programPhotos.isNotEmpty) filledFields++;

    return (filledFields / totalFields) * 100;
  }

  /// Check if profile meets minimum completion requirements
  bool get isMinimumComplete {
    return displayName.isNotEmpty &&
           bio != null &&
           profileImageUrl != null &&
           schoolName != null &&
           programName != null &&
           division != null &&
           coachingTitle != null &&
           completionPercentage >= 70.0;
  }

  /// Get recruiting summary text
  String get recruitingSummary {
    if (recruitingPositions.isEmpty) return 'Open to all positions';
    
    String positions = recruitingPositions.map((p) => p.displayName).join(', ');
    String regions = targetRegions.isNotEmpty 
        ? ' in ${targetRegions.join(', ')}'
        : '';
    
    return 'Recruiting $positions$regions';
  }
}