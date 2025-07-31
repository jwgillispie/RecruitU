import '../entities/player_profile_entity.dart';
import '../entities/coach_profile_entity.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/player_profile_model.dart';
import '../../data/models/coach_profile_model.dart';

/// Use case for creating profiles from form data
class CreateProfileFromFormUseCase {
  final ProfileRepository _repository;

  CreateProfileFromFormUseCase(this._repository);

  /// Create player profile from form data
  Future<PlayerProfileEntity> createPlayerProfile({
    required String userId,
    required String displayName,
    required Map<String, dynamic> formData,
  }) async {
    try {
      print('📝 CREATE_PROFILE_USECASE: Creating player profile');
      print('📝 CREATE_PROFILE_USECASE: UserId: $userId');
      print('📝 CREATE_PROFILE_USECASE: DisplayName: $displayName');
      print('📝 CREATE_PROFILE_USECASE: FormData: $formData');
      
      // Create profile model from form data
      final profileModel = PlayerProfileModel.fromFormData(
        userId: userId,
        displayName: displayName,
        formData: formData,
      );
      
      // Calculate completion and create in repository
      final completedProfile = profileModel.copyWithCompletion();
      
      print('📝 CREATE_PROFILE_USECASE: Profile completion: ${completedProfile.completionPercentage}%');
      
      final createdProfile = await _repository.createPlayerProfile(completedProfile);
      
      print('📝 CREATE_PROFILE_USECASE: Player profile created successfully with ID: ${createdProfile.id}');
      return createdProfile;
    } catch (e) {
      print('📝 CREATE_PROFILE_USECASE: Error creating player profile: $e');
      throw Exception('Failed to create player profile: ${e.toString()}');
    }
  }

  /// Create coach profile from form data
  Future<CoachProfileEntity> createCoachProfile({
    required String userId,
    required String displayName,
    required Map<String, dynamic> formData,
  }) async {
    try {
      print('📝 CREATE_PROFILE_USECASE: Creating coach profile');
      print('📝 CREATE_PROFILE_USECASE: UserId: $userId');
      print('📝 CREATE_PROFILE_USECASE: DisplayName: $displayName');
      print('📝 CREATE_PROFILE_USECASE: FormData: $formData');
      
      // Create profile model from form data
      final profileModel = CoachProfileModel.fromFormData(
        userId: userId,
        displayName: displayName,
        formData: formData,
      );
      
      // Calculate completion and create in repository
      final completedProfile = profileModel.copyWithCompletion();
      
      print('📝 CREATE_PROFILE_USECASE: Profile completion: ${completedProfile.completionPercentage}%');
      
      final createdProfile = await _repository.createCoachProfile(completedProfile);
      
      print('📝 CREATE_PROFILE_USECASE: Coach profile created successfully with ID: ${createdProfile.id}');
      return createdProfile;
    } catch (e) {
      print('📝 CREATE_PROFILE_USECASE: Error creating coach profile: $e');
      throw Exception('Failed to create coach profile: ${e.toString()}');
    }
  }

  /// Create profile based on user type
  Future<dynamic> createProfile({
    required String userId,
    required String displayName,
    required UserType userType,
    required Map<String, dynamic> formData,
  }) async {
    switch (userType) {
      case UserType.player:
        return await createPlayerProfile(
          userId: userId,
          displayName: displayName,
          formData: formData,
        );
      case UserType.coach:
        return await createCoachProfile(
          userId: userId,
          displayName: displayName,
          formData: formData,
        );
      default:
        throw Exception('Unsupported user type: $userType');
    }
  }
}