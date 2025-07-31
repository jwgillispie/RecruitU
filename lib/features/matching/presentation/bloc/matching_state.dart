import 'package:equatable/equatable.dart';
import '../../domain/entities/match_entity.dart';

abstract class MatchingState extends Equatable {
  const MatchingState();

  @override
  List<Object?> get props => [];
}

class MatchingInitial extends MatchingState {}

class MatchingLoading extends MatchingState {}

class MatchingLoaded extends MatchingState {
  final List<MatchEntity> matches;

  const MatchingLoaded(this.matches);

  @override
  List<Object?> get props => [matches];
}

class MatchingError extends MatchingState {
  final String message;

  const MatchingError(this.message);

  @override
  List<Object?> get props => [message];
}

class SwipeSuccess extends MatchingState {
  final bool isMatch;
  final MatchEntity? match;

  const SwipeSuccess({
    required this.isMatch,
    this.match,
  });

  @override
  List<Object?> get props => [isMatch, match];
}

class SwipeError extends MatchingState {
  final String message;

  const SwipeError(this.message);

  @override
  List<Object?> get props => [message];
}

class UnmatchSuccess extends MatchingState {}

class UnmatchError extends MatchingState {
  final String message;

  const UnmatchError(this.message);

  @override
  List<Object?> get props => [message];
}