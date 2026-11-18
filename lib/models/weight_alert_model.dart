
import 'package:cloud_firestore/cloud_firestore.dart';

//////////////////////////////////////////WEIGHT ALERT MODEL//////////////////////////////////////////
class WeightAlert { 
  final String id;
  final String catId;
  final String type;

  final double previousWeight;
  final double currentWeight;
  final double weightChange;

  final DateTime timestamp;
  final DateTime? acknowledgedAt;

  final String status;

  WeightAlert({
    required this.id,
    required this.catId,
    required this.type,
    required this.previousWeight,
    required this.currentWeight,
    required this.weightChange,
    required this.timestamp,
    this.acknowledgedAt,
    required this.status,
  });

  //////////////////////////////////////////FROM FIRESTORE//////////////////////////////////////////
  factory WeightAlert.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return WeightAlert(
      id: doc.id,
      catId: data['catId'] ?? '',
      type: data['type'] ?? '',
      previousWeight:
          (data['previousWeight'] as num).toDouble(),
      currentWeight:
          (data['currentWeight'] as num).toDouble(),
      weightChange:
          (data['weightChange'] as num).toDouble(),
      timestamp:
          (data['timestamp'] as Timestamp).toDate(),
      acknowledgedAt:
          (data['acknowledgedAt'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'active',
    );
  }

  //////////////////////////////////////////TO FIRESTORE//////////////////////////////////////////
  Map<String, dynamic> toFirestore() {
    return {
      'catId': catId,
      'type': type,
      'previousWeight': previousWeight,
      'currentWeight': currentWeight,
      'weightChange': weightChange,
      'timestamp': Timestamp.fromDate(timestamp),
      'acknowledgedAt': acknowledgedAt == null
          ? null
          : Timestamp.fromDate(acknowledgedAt!),
      'status': status,
    };
  }
}
