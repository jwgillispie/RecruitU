import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  const MatchModel({
    required super.id,
    required super.userId1,
    required super.userId2,
    required super.userName1,
    required super.userName2,
    super.userProfileImage1,
    super.userProfileImage2,
    required super.matchedAt,
    super.hasUnreadMessages,
    super.lastMessageText,
    super.lastMessageAt,
    super.lastMessageSenderId,
    super.isActive,
  });

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchModel(
      id: doc.id,
      userId1: data['userId1'] ?? '',
      userId2: data['userId2'] ?? '',
      userName1: data['userName1'] ?? '',
      userName2: data['userName2'] ?? '',
      userProfileImage1: data['userProfileImage1'],
      userProfileImage2: data['userProfileImage2'],
      matchedAt: (data['matchedAt'] as Timestamp).toDate(),
      hasUnreadMessages: data['hasUnreadMessages'] ?? false,
      lastMessageText: data['lastMessageText'],
      lastMessageAt: data['lastMessageAt'] != null
          ? (data['lastMessageAt'] as Timestamp).toDate()
          : null,
      lastMessageSenderId: data['lastMessageSenderId'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId1': userId1,
      'userId2': userId2,
      'userName1': userName1,
      'userName2': userName2,
      'userProfileImage1': userProfileImage1,
      'userProfileImage2': userProfileImage2,
      'matchedAt': Timestamp.fromDate(matchedAt),
      'hasUnreadMessages': hasUnreadMessages,
      'lastMessageText': lastMessageText,
      'lastMessageAt': lastMessageAt != null
          ? Timestamp.fromDate(lastMessageAt!)
          : null,
      'lastMessageSenderId': lastMessageSenderId,
      'isActive': isActive,
    };
  }

  factory MatchModel.fromEntity(MatchEntity entity) {
    return MatchModel(
      id: entity.id,
      userId1: entity.userId1,
      userId2: entity.userId2,
      userName1: entity.userName1,
      userName2: entity.userName2,
      userProfileImage1: entity.userProfileImage1,
      userProfileImage2: entity.userProfileImage2,
      matchedAt: entity.matchedAt,
      hasUnreadMessages: entity.hasUnreadMessages,
      lastMessageText: entity.lastMessageText,
      lastMessageAt: entity.lastMessageAt,
      lastMessageSenderId: entity.lastMessageSenderId,
      isActive: entity.isActive,
    );
  }
}