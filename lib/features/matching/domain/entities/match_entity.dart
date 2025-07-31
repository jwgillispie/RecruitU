import 'package:equatable/equatable.dart';

/// Represents a match between two users in the RecruitU platform
class MatchEntity extends Equatable {
  final String id;
  final String userId1;
  final String userId2;
  final String userName1;
  final String userName2;
  final String? userProfileImage1;
  final String? userProfileImage2;
  final DateTime matchedAt;
  final bool hasUnreadMessages;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final bool isActive;

  const MatchEntity({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.userName1,
    required this.userName2,
    this.userProfileImage1,
    this.userProfileImage2,
    required this.matchedAt,
    this.hasUnreadMessages = false,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastMessageSenderId,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        userId1,
        userId2,
        userName1,
        userName2,
        userProfileImage1,
        userProfileImage2,
        matchedAt,
        hasUnreadMessages,
        lastMessageText,
        lastMessageAt,
        lastMessageSenderId,
        isActive,
      ];

  /// Get the other user's name based on current user ID
  String getOtherUserName(String currentUserId) {
    return currentUserId == userId1 ? userName2 : userName1;
  }

  /// Get the other user's profile image based on current user ID
  String? getOtherUserProfileImage(String currentUserId) {
    return currentUserId == userId1 ? userProfileImage2 : userProfileImage1;
  }

  /// Get the other user's ID based on current user ID
  String getOtherUserId(String currentUserId) {
    return currentUserId == userId1 ? userId2 : userId1;
  }

  /// Check if the current user sent the last message
  bool didCurrentUserSendLastMessage(String currentUserId) {
    return lastMessageSenderId == currentUserId;
  }

  /// Get formatted time for the last message
  String getFormattedLastMessageTime() {
    if (lastMessageAt == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt!);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w';
    }
  }

  MatchEntity copyWith({
    String? id,
    String? userId1,
    String? userId2,
    String? userName1,
    String? userName2,
    String? userProfileImage1,
    String? userProfileImage2,
    DateTime? matchedAt,
    bool? hasUnreadMessages,
    String? lastMessageText,
    DateTime? lastMessageAt,
    String? lastMessageSenderId,
    bool? isActive,
  }) {
    return MatchEntity(
      id: id ?? this.id,
      userId1: userId1 ?? this.userId1,
      userId2: userId2 ?? this.userId2,
      userName1: userName1 ?? this.userName1,
      userName2: userName2 ?? this.userName2,
      userProfileImage1: userProfileImage1 ?? this.userProfileImage1,
      userProfileImage2: userProfileImage2 ?? this.userProfileImage2,
      matchedAt: matchedAt ?? this.matchedAt,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      isActive: isActive ?? this.isActive,
    );
  }
}