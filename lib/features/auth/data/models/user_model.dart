import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';

/// User model for data layer
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.userType,
    super.phoneNumber,
    super.profileImageUrl,
    required super.createdAt,
    required super.lastActiveAt,
    super.isVerified = false,
    super.isPremium = false,
    super.isProfileComplete = false,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      userType: UserType.values.firstWhere(
        (type) => type.toString().split('.').last == json['userType'],
      ),
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastActiveAt: (json['lastActiveAt'] as Timestamp).toDate(),
      isVerified: json['isVerified'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
    );
  }

  /// Create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'userType': userType.toString().split('.').last,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'isVerified': isVerified,
      'isPremium': isPremium,
      'isProfileComplete': isProfileComplete,
    };
  }

  /// Convert UserModel to Firestore data (excludes ID)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Remove ID as it's handled by Firestore document ID
    return json;
  }

  /// Create UserModel from UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      userType: entity.userType,
      phoneNumber: entity.phoneNumber,
      profileImageUrl: entity.profileImageUrl,
      createdAt: entity.createdAt,
      lastActiveAt: entity.lastActiveAt,
      isVerified: entity.isVerified,
      isPremium: entity.isPremium,
      isProfileComplete: entity.isProfileComplete,
    );
  }

  @override
  UserModel copyWith({
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
    return UserModel(
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