import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

/// User entity representing a user in the domain layer
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final UserType userType;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final bool isVerified;
  final bool isPremium;
  final bool isProfileComplete;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.userType,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    required this.lastActiveAt,
    this.isVerified = false,
    this.isPremium = false,
    this.isProfileComplete = false,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        userType,
        phoneNumber,
        profileImageUrl,
        createdAt,
        lastActiveAt,
        isVerified,
        isPremium,
        isProfileComplete,
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    UserType? userType,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? isVerified,
    bool? isPremium,
    bool? isProfileComplete,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      userType: userType ?? this.userType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}