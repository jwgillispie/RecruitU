import 'package:uuid/uuid.dart';
import '../entities/swipe_action_entity.dart';
import '../entities/match_entity.dart';
import '../repositories/matching_repository.dart';

class SwipeUserUseCase {
  final MatchingRepository _repository;

  SwipeUserUseCase(this._repository);

  Future<SwipeResult> call(SwipeUserParams params) async {
    try {
      // Check if user already swiped on this profile
      final hasAlreadySwiped = await _repository.hasUserAlreadySwiped(
        params.fromUserId,
        params.toUserId,
      );

      if (hasAlreadySwiped) {
        return SwipeResult.alreadySwiped();
      }

      // Record the swipe action
      final swipeAction = SwipeActionEntity(
        id: const Uuid().v4(),
        fromUserId: params.fromUserId,
        toUserId: params.toUserId,
        action: params.action,
        timestamp: DateTime.now(),
      );

      await _repository.recordSwipeAction(swipeAction);

      // If it's a like, check for a match
      if (params.action == SwipeAction.like) {
        final isMatch = await _repository.checkForMatch(
          params.fromUserId,
          params.toUserId,
        );

        if (isMatch) {
          // Create the match
          final match = await _repository.createMatch(
            params.fromUserId,
            params.toUserId,
          );

          if (match != null) {
            return SwipeResult.match(match);
          }
        }
      }

      return SwipeResult.success();
    } catch (e) {
      return SwipeResult.error(e.toString());
    }
  }
}

class SwipeUserParams {
  final String fromUserId;
  final String toUserId;
  final SwipeAction action;

  SwipeUserParams({
    required this.fromUserId,
    required this.toUserId,
    required this.action,
  });
}

class SwipeResult {
  final bool isSuccess;
  final bool isMatch;
  final bool isAlreadySwiped;
  final MatchEntity? match;
  final String? error;

  SwipeResult._({
    required this.isSuccess,
    required this.isMatch,
    required this.isAlreadySwiped,
    this.match,
    this.error,
  });

  factory SwipeResult.success() => SwipeResult._(
        isSuccess: true,
        isMatch: false,
        isAlreadySwiped: false,
      );

  factory SwipeResult.match(MatchEntity match) => SwipeResult._(
        isSuccess: true,
        isMatch: true,
        isAlreadySwiped: false,
        match: match,
      );

  factory SwipeResult.alreadySwiped() => SwipeResult._(
        isSuccess: false,
        isMatch: false,
        isAlreadySwiped: true,
      );

  factory SwipeResult.error(String error) => SwipeResult._(
        isSuccess: false,
        isMatch: false,
        isAlreadySwiped: false,
        error: error,
      );
}