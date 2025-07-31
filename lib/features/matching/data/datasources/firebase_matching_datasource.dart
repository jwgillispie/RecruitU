import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';
import '../models/swipe_action_model.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/swipe_action_entity.dart';

class FirebaseMatchingDatasource {
  final FirebaseFirestore _firestore;

  FirebaseMatchingDatasource(this._firestore);

  static const String _swipeActionsCollection = 'swipe_actions';
  static const String _matchesCollection = 'matches';

  // Swipe Actions
  Future<void> recordSwipeAction(SwipeActionEntity swipeAction) async {
    final swipeActionModel = SwipeActionModel.fromEntity(swipeAction);
    await _firestore
        .collection(_swipeActionsCollection)
        .doc(swipeAction.id)
        .set(swipeActionModel.toFirestore());
  }

  Future<bool> hasUserAlreadySwiped(String fromUserId, String toUserId) async {
    final querySnapshot = await _firestore
        .collection(_swipeActionsCollection)
        .where('fromUserId', isEqualTo: fromUserId)
        .where('toUserId', isEqualTo: toUserId)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<SwipeActionEntity?> getSwipeAction(String fromUserId, String toUserId) async {
    final querySnapshot = await _firestore
        .collection(_swipeActionsCollection)
        .where('fromUserId', isEqualTo: fromUserId)
        .where('toUserId', isEqualTo: toUserId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    return SwipeActionModel.fromFirestore(querySnapshot.docs.first);
  }

  // Match Management
  Future<MatchEntity?> createMatch(String userId1, String userId2, String userName1, String userName2, 
      String? userProfileImage1, String? userProfileImage2) async {
    try {
      final matchData = {
        'userId1': userId1,
        'userId2': userId2,
        'userName1': userName1,
        'userName2': userName2,
        'userProfileImage1': userProfileImage1,
        'userProfileImage2': userProfileImage2,
        'matchedAt': Timestamp.now(),
        'hasUnreadMessages': false,
        'lastMessageText': null,
        'lastMessageAt': null,
        'lastMessageSenderId': null,
        'isActive': true,
      };

      final docRef = await _firestore
          .collection(_matchesCollection)
          .add(matchData);

      final doc = await docRef.get();
      return MatchModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to create match: $e');
    }
  }

  Future<List<MatchEntity>> getUserMatches(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_matchesCollection)
          .where('userId1', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      final querySnapshot2 = await _firestore
          .collection(_matchesCollection)
          .where('userId2', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      final allDocs = [...querySnapshot.docs, ...querySnapshot2.docs];
      return allDocs.map((doc) => MatchModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get user matches: $e');
    }
  }

  Future<MatchEntity?> getMatch(String matchId) async {
    try {
      final doc = await _firestore
          .collection(_matchesCollection)
          .doc(matchId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return MatchModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get match: $e');
    }
  }

  Future<void> updateMatch(MatchEntity match) async {
    try {
      final matchModel = MatchModel.fromEntity(match);
      await _firestore
          .collection(_matchesCollection)
          .doc(match.id)
          .update(matchModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to update match: $e');
    }
  }

  Future<void> deleteMatch(String matchId) async {
    try {
      await _firestore
          .collection(_matchesCollection)
          .doc(matchId)
          .update({'isActive': false});
    } catch (e) {
      throw Exception('Failed to delete match: $e');
    }
  }

  // Match Checking
  Future<bool> checkForMatch(String userId1, String userId2) async {
    try {
      // Check if both users have liked each other
      final user1LikedUser2 = await _firestore
          .collection(_swipeActionsCollection)
          .where('fromUserId', isEqualTo: userId1)
          .where('toUserId', isEqualTo: userId2)
          .where('action', isEqualTo: 'like')
          .limit(1)
          .get();

      final user2LikedUser1 = await _firestore
          .collection(_swipeActionsCollection)
          .where('fromUserId', isEqualTo: userId2)
          .where('toUserId', isEqualTo: userId1)
          .where('action', isEqualTo: 'like')
          .limit(1)
          .get();

      return user1LikedUser2.docs.isNotEmpty && user2LikedUser1.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check for match: $e');
    }
  }

  Future<List<String>> getMatchCandidates(String userId) async {
    try {
      // Get all users that this user has NOT swiped on yet
      final swipedUsers = await _firestore
          .collection(_swipeActionsCollection)
          .where('fromUserId', isEqualTo: userId)
          .get();

      final swipedUserIds = swipedUsers.docs
          .map((doc) => doc.data()['toUserId'] as String)
          .toList();

      // For now, return empty list as we need to implement profile discovery
      // This would typically fetch from a users/profiles collection
      return [];
    } catch (e) {
      throw Exception('Failed to get match candidates: $e');
    }
  }

  // Real-time updates
  Stream<List<MatchEntity>> watchUserMatches(String userId) {
    return _firestore
        .collection(_matchesCollection)
        .where('userId1', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot1) async {
          final snapshot2 = await _firestore
              .collection(_matchesCollection)
              .where('userId2', isEqualTo: userId)
              .where('isActive', isEqualTo: true)
              .get();

          final allDocs = [...snapshot1.docs, ...snapshot2.docs];
          return allDocs.map((doc) => MatchModel.fromFirestore(doc)).toList();
        });
  }

  Stream<MatchEntity> watchMatch(String matchId) {
    return _firestore
        .collection(_matchesCollection)
        .doc(matchId)
        .snapshots()
        .map((doc) => MatchModel.fromFirestore(doc));
  }
}