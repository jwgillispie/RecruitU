import 'package:equatable/equatable.dart';

enum SwipeAction { like, pass }

class SwipeActionEntity extends Equatable {
  final String id;
  final String fromUserId;
  final String toUserId;
  final SwipeAction action;
  final DateTime timestamp;

  const SwipeActionEntity({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.action,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        toUserId,
        action,
        timestamp,
      ];

  SwipeActionEntity copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    SwipeAction? action,
    DateTime? timestamp,
  }) {
    return SwipeActionEntity(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}