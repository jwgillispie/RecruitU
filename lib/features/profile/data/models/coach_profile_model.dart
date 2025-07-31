import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/coach_profile_entity.dart';
import '../../../../core/constants/app_constants.dart';

/// Data model for coach profile with Firestore serialization
class CoachProfileModel extends CoachProfileEntity {
  const CoachProfileModel({
    required super.id,
    required super.userId,
    required super.displayName,
    super.bio,
    super.profileImageUrl,
    super.phoneNumber,
    super.email,
    super.officialEmail,
    super.location,
    super.schoolName,
    super.programName,
    super.division,
    super.conference,
    super.leagueName,
    super.teamName,
    super.season,
    super.coachingTitle,
    super.yearsCoaching,
    super.yearsAtCurrentProgram,
    super.recruitingPositions,
    super.targetRegions,
    super.graduationYearTargets,
    super.recruitingPhilosophy,
    super.coachingPhilosophy,
    super.programHistory,
    super.programAchievements,
    super.facilitiesDescription,
    super.scholarshipInfo,
    super.websiteUrl,
    super.twitterHandle,
    super.instagramHandle,
    super.linkedinUrl,
    super.programPhotos,
    super.facilityPhotos,
    super.teamVideos,
    super.isVerified,
    super.isProgramOfficial,
    super.verificationDocuments,
    super.isPublic,
    super.acceptingRecruits,
    super.allowDirectContact,
    required super.createdAt,
    required super.updatedAt,
    super.isProfileComplete,
    super.completionPercentage,
  });

  /// Create from Firestore document
  factory CoachProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CoachProfileModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      bio: data['bio'],
      profileImageUrl: data['profileImageUrl'],
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      officialEmail: data['officialEmail'],
      location: data['location'],
      schoolName: data['schoolName'],
      programName: data['programName'],
      division: _divisionFromString(data['division']),
      conference: data['conference'],
      leagueName: data['leagueName'],
      teamName: data['teamName'],
      season: data['season'],
      coachingTitle: data['coachingTitle'],
      yearsCoaching: data['yearsCoaching']?.toInt(),
      yearsAtCurrentProgram: data['yearsAtCurrentProgram']?.toInt(),
      recruitingPositions: _positionsFromList(data['recruitingPositions'] ?? []),
      targetRegions: List<String>.from(data['targetRegions'] ?? []),
      graduationYearTargets: data['graduationYearTargets'],
      recruitingPhilosophy: data['recruitingPhilosophy'],
      coachingPhilosophy: data['coachingPhilosophy'],
      programHistory: data['programHistory'],
      programAchievements: List<String>.from(data['programAchievements'] ?? []),
      facilitiesDescription: data['facilitiesDescription'],
      scholarshipInfo: data['scholarshipInfo'],
      websiteUrl: data['websiteUrl'],
      twitterHandle: data['twitterHandle'],
      instagramHandle: data['instagramHandle'],
      linkedinUrl: data['linkedinUrl'],
      programPhotos: List<String>.from(data['programPhotos'] ?? []),
      facilityPhotos: List<String>.from(data['facilityPhotos'] ?? []),
      teamVideos: List<String>.from(data['teamVideos'] ?? []),
      isVerified: data['isVerified'] ?? false,
      isProgramOfficial: data['isProgramOfficial'] ?? false,
      verificationDocuments: data['verificationDocuments'],
      isPublic: data['isPublic'] ?? true,
      acceptingRecruits: data['acceptingRecruits'] ?? true,
      allowDirectContact: data['allowDirectContact'] ?? true,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
      isProfileComplete: data['isProfileComplete'] ?? false,
      completionPercentage: data['completionPercentage']?.toDouble() ?? 0.0,
    );
  }

  /// Create from form data (for profile completion)
  factory CoachProfileModel.fromFormData({
    required String userId,
    required String displayName,
    required Map<String, dynamic> formData,
  }) {
    final now = DateTime.now();
    
    return CoachProfileModel(
      id: '', // Will be set by Firestore
      userId: userId,
      displayName: displayName,
      bio: formData['bio'],
      profileImageUrl: formData['profilePhotoUrl'],
      phoneNumber: formData['phoneNumber'],
      officialEmail: formData['officialEmail'],
      location: formData['location'],
      schoolName: formData['schoolName'],
      coachingTitle: formData['coachingTitle'],
      conference: formData['conference'],
      yearsCoaching: formData['yearsCoaching'] != null 
          ? int.tryParse(formData['yearsCoaching']) 
          : null,
      recruitingPositions: const [], // Initialize empty list
      targetRegions: const [], // Initialize empty list
      programAchievements: const [], // Initialize empty list
      programPhotos: const [], // Initialize empty list
      facilityPhotos: const [], // Initialize empty list
      teamVideos: const [], // Initialize empty list
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
      'email': email,
      'officialEmail': officialEmail,
      'location': location,
      'schoolName': schoolName,
      'programName': programName,
      'division': division?.name,
      'conference': conference,
      'leagueName': leagueName,
      'teamName': teamName,
      'season': season,
      'coachingTitle': coachingTitle,
      'yearsCoaching': yearsCoaching,
      'yearsAtCurrentProgram': yearsAtCurrentProgram,
      'recruitingPositions': recruitingPositions.map((p) => p.name).toList(),
      'targetRegions': targetRegions,
      'graduationYearTargets': graduationYearTargets,
      'recruitingPhilosophy': recruitingPhilosophy,
      'coachingPhilosophy': coachingPhilosophy,
      'programHistory': programHistory,
      'programAchievements': programAchievements,
      'facilitiesDescription': facilitiesDescription,
      'scholarshipInfo': scholarshipInfo,
      'websiteUrl': websiteUrl,
      'twitterHandle': twitterHandle,
      'instagramHandle': instagramHandle,
      'linkedinUrl': linkedinUrl,
      'programPhotos': programPhotos,
      'facilityPhotos': facilityPhotos,
      'teamVideos': teamVideos,
      'isVerified': isVerified,
      'isProgramOfficial': isProgramOfficial,
      'verificationDocuments': verificationDocuments,
      'isPublic': isPublic,
      'acceptingRecruits': acceptingRecruits,
      'allowDirectContact': allowDirectContact,
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

  /// Copy with updated completion data
  CoachProfileModel copyWithCompletion() {
    final completionPercentage = calculateCompletionPercentage();
    
    return CoachProfileModel(
      id: id,
      userId: userId,
      displayName: displayName,
      bio: bio,
      profileImageUrl: profileImageUrl,
      phoneNumber: phoneNumber,
      email: email,
      officialEmail: officialEmail,
      location: location,
      schoolName: schoolName,
      programName: programName,
      division: division,
      conference: conference,
      leagueName: leagueName,
      teamName: teamName,
      season: season,
      coachingTitle: coachingTitle,
      yearsCoaching: yearsCoaching,
      yearsAtCurrentProgram: yearsAtCurrentProgram,
      recruitingPositions: recruitingPositions,
      targetRegions: targetRegions,
      graduationYearTargets: graduationYearTargets,
      recruitingPhilosophy: recruitingPhilosophy,
      coachingPhilosophy: coachingPhilosophy,
      programHistory: programHistory,
      programAchievements: programAchievements,
      facilitiesDescription: facilitiesDescription,
      scholarshipInfo: scholarshipInfo,
      websiteUrl: websiteUrl,
      twitterHandle: twitterHandle,
      instagramHandle: instagramHandle,
      linkedinUrl: linkedinUrl,
      programPhotos: programPhotos,
      facilityPhotos: facilityPhotos,
      teamVideos: teamVideos,
      isVerified: isVerified,
      isProgramOfficial: isProgramOfficial,
      verificationDocuments: verificationDocuments,
      isPublic: isPublic,
      acceptingRecruits: acceptingRecruits,
      allowDirectContact: allowDirectContact,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isProfileComplete: completionPercentage >= 70.0,
      completionPercentage: completionPercentage,
    );
  }
}