import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/swipe_user_usecase.dart';
import '../../domain/usecases/get_matches_usecase.dart';
import '../../domain/usecases/unmatch_usecase.dart';
import '../../domain/entities/match_entity.dart';
import 'matching_event.dart';
import 'matching_state.dart';

class MatchingBloc extends Bloc<MatchingEvent, MatchingState> {
  final SwipeUserUseCase _swipeUserUseCase;
  final GetMatchesUseCase _getMatchesUseCase;
  final WatchMatchesUseCase _watchMatchesUseCase;
  final UnmatchUseCase _unmatchUseCase;

  StreamSubscription<List<MatchEntity>>? _matchesSubscription;

  MatchingBloc({
    required SwipeUserUseCase swipeUserUseCase,
    required GetMatchesUseCase getMatchesUseCase,
    required WatchMatchesUseCase watchMatchesUseCase,
    required UnmatchUseCase unmatchUseCase,
  })  : _swipeUserUseCase = swipeUserUseCase,
        _getMatchesUseCase = getMatchesUseCase,
        _watchMatchesUseCase = watchMatchesUseCase,
        _unmatchUseCase = unmatchUseCase,
        super(MatchingInitial()) {
    on<LoadMatches>(_onLoadMatches);
    on<SwipeUser>(_onSwipeUser);
    on<UnmatchUser>(_onUnmatchUser);
    on<WatchMatches>(_onWatchMatches);
    on<MatchesUpdated>(_onMatchesUpdated);
  }

  Future<void> _onLoadMatches(
    LoadMatches event,
    Emitter<MatchingState> emit,
  ) async {
    try {
      emit(MatchingLoading());
      final matches = await _getMatchesUseCase(event.userId);
      emit(MatchingLoaded(matches));
    } catch (e) {
      emit(MatchingError(e.toString()));
    }
  }

  Future<void> _onSwipeUser(
    SwipeUser event,
    Emitter<MatchingState> emit,
  ) async {
    try {
      final params = SwipeUserParams(
        fromUserId: event.fromUserId,
        toUserId: event.toUserId,
        action: event.action,
      );

      final result = await _swipeUserUseCase(params);

      if (result.isSuccess) {
        emit(SwipeSuccess(
          isMatch: result.isMatch,
          match: result.match,
        ));
      } else if (result.isAlreadySwiped) {
        emit(const SwipeError('You have already swiped on this profile'));
      } else {
        emit(SwipeError(result.error ?? 'Unknown error occurred'));
      }
    } catch (e) {
      emit(SwipeError(e.toString()));
    }
  }

  Future<void> _onUnmatchUser(
    UnmatchUser event,
    Emitter<MatchingState> emit,
  ) async {
    try {
      await _unmatchUseCase(event.matchId);
      emit(UnmatchSuccess());
    } catch (e) {
      emit(UnmatchError(e.toString()));
    }
  }

  Future<void> _onWatchMatches(
    WatchMatches event,
    Emitter<MatchingState> emit,
  ) async {
    await _matchesSubscription?.cancel();
    _matchesSubscription = _watchMatchesUseCase(event.userId).listen(
      (matches) => add(MatchesUpdated(matches)),
    );
  }

  Future<void> _onMatchesUpdated(
    MatchesUpdated event,
    Emitter<MatchingState> emit,
  ) async {
    final matches = event.matches.cast<MatchEntity>();
    emit(MatchingLoaded(matches));
  }

  @override
  Future<void> close() {
    _matchesSubscription?.cancel();
    return super.close();
  }
}