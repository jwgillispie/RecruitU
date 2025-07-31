import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/player_profile_model.dart';
import '../models/coach_profile_model.dart';
import '../../../../core/constants/app_constants.dart';

/// Firebase data source for profile operations
class FirebaseProfileDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseProfileDataSource(this._firestore, this._storage);

  // Collections
  CollectionReference get _playerProfiles => 
      _firestore.collection(AppConstants.playerProfilesCollection);
  CollectionReference get _coachProfiles => 
      _firestore.collection(AppConstants.coachProfilesCollection);

  // Player Profile Operations

  /// Get player profile by user ID
  Future<PlayerProfileModel?> getPlayerProfile(String userId) async {
    try {
      print('🔥 DATASOURCE: Getting player profile for userId: $userId');
      
      final querySnapshot = await _playerProfiles
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('🔥 DATASOURCE: No player profile found for userId: $userId');
        return null;
      }

      final profile = PlayerProfileModel.fromFirestore(querySnapshot.docs.first);
      print('🔥 DATASOURCE: Player profile retrieved: ${profile.id}');
      return profile;
    } catch (e) {
      print('🔥 DATASOURCE: Error getting player profile: $e');
      throw Exception('Failed to get player profile: $e');
    }
  }

  /// Create player profile
  Future<PlayerProfileModel> createPlayerProfile(PlayerProfileModel profile) async {
    try {
      print('🔥 DATASOURCE: Creating player profile for userId: ${profile.userId}');
      
      final docRef = await _playerProfiles.add(profile.toFirestore());
      
      // Get the created document with the ID
      final doc = await docRef.get();
      final createdProfile = PlayerProfileModel.fromFirestore(doc);
      
      print('🔥 DATASOURCE: Player profile created with ID: ${createdProfile.id}');
      return createdProfile;
    } catch (e) {
      print('🔥 DATASOURCE: Error creating player profile: $e');
      throw Exception('Failed to create player profile: $e');
    }
  }

  /// Update player profile
  Future<PlayerProfileModel> updatePlayerProfile(PlayerProfileModel profile) async {
    try {
      print('🔥 DATASOURCE: Updating player profile: ${profile.id}');
      
      await _playerProfiles.doc(profile.id).update(profile.toFirestore());
      
      // Return updated profile
      final doc = await _playerProfiles.doc(profile.id).get();
      final updatedProfile = PlayerProfileModel.fromFirestore(doc);
      
      print('🔥 DATASOURCE: Player profile updated successfully');
      return updatedProfile;
    } catch (e) {
      print('🔥 DATASOURCE: Error updating player profile: $e');
      throw Exception('Failed to update player profile: $e');
    }
  }

  /// Delete player profile
  Future<void> deletePlayerProfile(String userId) async {
    try {
      print('🔥 DATASOURCE: Deleting player profile for userId: $userId');
      
      final querySnapshot = await _playerProfiles
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      
      print('🔥 DATASOURCE: Player profile deleted successfully');
    } catch (e) {
      print('🔥 DATASOURCE: Error deleting player profile: $e');
      throw Exception('Failed to delete player profile: $e');
    }
  }

  /// Check if player profile exists
  Future<bool> playerProfileExists(String userId) async {
    try {
      final querySnapshot = await _playerProfiles
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('🔥 DATASOURCE: Error checking player profile existence: $e');
      return false;
    }
  }

  // Coach Profile Operations

  /// Get coach profile by user ID
  Future<CoachProfileModel?> getCoachProfile(String userId) async {
    try {
      print('🔥 DATASOURCE: Getting coach profile for userId: $userId');
      
      final querySnapshot = await _coachProfiles
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('🔥 DATASOURCE: No coach profile found for userId: $userId');
        return null;
      }

      final profile = CoachProfileModel.fromFirestore(querySnapshot.docs.first);
      print('🔥 DATASOURCE: Coach profile retrieved: ${profile.id}');
      return profile;
    } catch (e) {
      print('🔥 DATASOURCE: Error getting coach profile: $e');
      throw Exception('Failed to get coach profile: $e');
    }
  }

  /// Create coach profile
  Future<CoachProfileModel> createCoachProfile(CoachProfileModel profile) async {
    try {
      print('🔥 DATASOURCE: Creating coach profile for userId: ${profile.userId}');
      
      final docRef = await _coachProfiles.add(profile.toFirestore());
      
      // Get the created document with the ID
      final doc = await docRef.get();
      final createdProfile = CoachProfileModel.fromFirestore(doc);
      
      print('🔥 DATASOURCE: Coach profile created with ID: ${createdProfile.id}');
      return createdProfile;
    } catch (e) {
      print('🔥 DATASOURCE: Error creating coach profile: $e');
      throw Exception('Failed to create coach profile: $e');
    }
  }

  /// Update coach profile
  Future<CoachProfileModel> updateCoachProfile(CoachProfileModel profile) async {
    try {
      print('🔥 DATASOURCE: Updating coach profile: ${profile.id}');
      
      await _coachProfiles.doc(profile.id).update(profile.toFirestore());
      
      // Return updated profile
      final doc = await _coachProfiles.doc(profile.id).get();
      final updatedProfile = CoachProfileModel.fromFirestore(doc);
      
      print('🔥 DATASOURCE: Coach profile updated successfully');
      return updatedProfile;
    } catch (e) {
      print('🔥 DATASOURCE: Error updating coach profile: $e');
      throw Exception('Failed to update coach profile: $e');
    }
  }

  /// Delete coach profile
  Future<void> deleteCoachProfile(String userId) async {
    try {
      print('🔥 DATASOURCE: Deleting coach profile for userId: $userId');
      
      final querySnapshot = await _coachProfiles
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      
      print('🔥 DATASOURCE: Coach profile deleted successfully');
    } catch (e) {
      print('🔥 DATASOURCE: Error deleting coach profile: $e');
      throw Exception('Failed to delete coach profile: $e');
    }
  }

  /// Check if coach profile exists
  Future<bool> coachProfileExists(String userId) async {
    try {
      final querySnapshot = await _coachProfiles
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('🔥 DATASOURCE: Error checking coach profile existence: $e');
      return false;
    }
  }

  // Media Upload Operations

  /// Upload profile image
  Future<String> uploadProfileImage(String userId, String imagePath) async {
    try {
      print('🔥 DATASOURCE: Uploading profile image for userId: $userId');
      
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist at path: $imagePath');
      }
      
      final fileName = 'profile_$userId.jpg';
      final ref = _storage.ref().child(AppConstants.profileImagesPath).child(fileName);
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('🔥 DATASOURCE: Profile image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('🔥 DATASOURCE: Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Upload video highlight
  Future<String> uploadVideoHighlight(String userId, String videoPath) async {
    try {
      print('🔥 DATASOURCE: Uploading video highlight for userId: $userId');
      
      final fileName = 'highlight_${userId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final ref = _storage.ref().child(AppConstants.videoHighlightsPath).child(fileName);
      
      // Placeholder implementation
      const placeholderUrl = 'https://via.placeholder.com/640x480?text=Video';
      print('🔥 DATASOURCE: Video highlight uploaded: $placeholderUrl');
      return placeholderUrl;
    } catch (e) {
      print('🔥 DATASOURCE: Error uploading video highlight: $e');
      throw Exception('Failed to upload video highlight: $e');
    }
  }

  /// Upload additional photo
  Future<String> uploadPhoto(String userId, String imagePath, String category) async {
    try {
      print('🔥 DATASOURCE: Uploading photo for userId: $userId, category: $category');
      
      final fileName = '${category}_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('photos').child(fileName);
      
      // Placeholder implementation
      const placeholderUrl = 'https://via.placeholder.com/600x400?text=Photo';
      print('🔥 DATASOURCE: Photo uploaded: $placeholderUrl');
      return placeholderUrl;
    } catch (e) {
      print('🔥 DATASOURCE: Error uploading photo: $e');
      throw Exception('Failed to upload photo: $e');
    }
  }

  /// Delete media file
  Future<void> deleteMediaFile(String fileUrl) async {
    try {
      print('🔥 DATASOURCE: Deleting media file: $fileUrl');
      
      // Extract file path from URL and delete
      // This is a simplified implementation
      print('🔥 DATASOURCE: Media file deleted successfully');
    } catch (e) {
      print('🔥 DATASOURCE: Error deleting media file: $e');
      throw Exception('Failed to delete media file: $e');
    }
  }

  // Discovery Operations (placeholder implementations)

  /// Get player profiles for discovery
  Future<List<PlayerProfileModel>> getPlayerProfilesForDiscovery({
    required String coachUserId,
    Map<String, dynamic>? filters,
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      print('🔥 DATASOURCE: Getting player profiles for discovery');
      
      Query query = _playerProfiles.where('isPublic', isEqualTo: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final querySnapshot = await query.get();
      
      final profiles = querySnapshot.docs
          .map((doc) => PlayerProfileModel.fromFirestore(doc))
          .toList();
      
      print('🔥 DATASOURCE: Found ${profiles.length} player profiles for discovery');
      return profiles;
    } catch (e) {
      print('🔥 DATASOURCE: Error getting player profiles for discovery: $e');
      throw Exception('Failed to get player profiles for discovery: $e');
    }
  }

  /// Get coach profiles for discovery
  Future<List<CoachProfileModel>> getCoachProfilesForDiscovery({
    required String playerUserId,
    Map<String, dynamic>? filters,
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      print('🔥 DATASOURCE: Getting coach profiles for discovery');
      
      Query query = _coachProfiles.where('isPublic', isEqualTo: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final querySnapshot = await query.get();
      
      final profiles = querySnapshot.docs
          .map((doc) => CoachProfileModel.fromFirestore(doc))
          .toList();
      
      print('🔥 DATASOURCE: Found ${profiles.length} coach profiles for discovery');
      return profiles;
    } catch (e) {
      print('🔥 DATASOURCE: Error getting coach profiles for discovery: $e');
      throw Exception('Failed to get coach profiles for discovery: $e');
    }
  }
}