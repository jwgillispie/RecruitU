import 'package:equatable/equatable.dart';
import '../../domain/entities/swipe_action_entity.dart';

abstract class MatchingEvent extends Equatable {
  const MatchingEvent();

  @override
  List<Object?> get props => [];
}

class LoadMatches extends MatchingEvent {
  final String userId;

  const LoadMatches(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SwipeUser extends MatchingEvent {
  final String fromUserId;
  final String toUserId;
  final SwipeAction action;

  const SwipeUser({
    required this.fromUserId,
    required this.toUserId,
    required this.action,
  });

  @override
  List<Object?> get props => [fromUserId, toUserId, action];
}

class UnmatchUser extends MatchingEvent {
  final String matchId;

  const UnmatchUser(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class WatchMatches extends MatchingEvent {
  final String userId;

  const WatchMatches(this.userId);

  @override
  List<Object?> get props => [userId];
}

class MatchesUpdated extends MatchingEvent {
  final List<dynamic> matches;

  const MatchesUpdated(this.matches);

  @override
  List<Object?> get props => [matches];
}