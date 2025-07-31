import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/swipe_action_entity.dart';

class SwipeActionModel extends SwipeActionEntity {
  const SwipeActionModel({
    required super.id,
    required super.fromUserId,
    required super.toUserId,
    required super.action,
    required super.timestamp,
  });

  factory SwipeActionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SwipeActionModel(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      toUserId: data['toUserId'] ?? '',
      action: SwipeAction.values.firstWhere(
        (e) => e.name == data['action'],
        orElse: () => SwipeAction.pass,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'action': action.name,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory SwipeActionModel.fromEntity(SwipeActionEntity entity) {
    return SwipeActionModel(
      id: entity.id,
      fromUserId: entity.fromUserId,
      toUserId: entity.toUserId,
      action: entity.action,
      timestamp: entity.timestamp,
    );
  }
}