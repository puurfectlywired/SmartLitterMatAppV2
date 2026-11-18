
import 'package:cloud_firestore/cloud_firestore.dart';


//////////////////////////////////////////FREQUENCY ALERT MODEL//////////////////////////////////////////
class FrequencyAlert {

  final String id;
  final String catId;
  final String type;

  final double averageVisits;
  final int currentVisits;
  final double percentChange;

  final DateTime timestamp;
  final DateTime? acknowledgedAt;

  final String status;

  const FrequencyAlert({
    required this.id,
    required this.catId,
    required this.type,
    required this.averageVisits,
    required this.currentVisits,
    required this.percentChange,
    required this.timestamp,
    this.acknowledgedAt,
    required this.status,
  });


  //////////////////////////////////////////FROM FIRESTORE//////////////////////////////////////////
  factory FrequencyAlert.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {

    final data = doc.data()!;

    return FrequencyAlert(
      id: doc.id,
      catId: data['catId'] as String? ?? '',
      type: data['type'] as String? ?? '',
      averageVisits:
          (data['averageVisits'] as num).toDouble(),
      currentVisits:
          (data['currentVisits'] as num).toInt(),
      percentChange:
          (data['percentChange'] as num).toDouble(),
      timestamp:
          (data['timestamp'] as Timestamp).toDate(),
      acknowledgedAt:
          (data['acknowledgedAt'] as Timestamp?)?.toDate(),
      status: data['status'] as String? ?? 'active',
    );
  }


  //////////////////////////////////////////TO FIRESTORE//////////////////////////////////////////
  Map<String, dynamic> toFirestore() {

    return {
      'catId': catId,
      'type': type,
      'averageVisits': averageVisits,
      'currentVisits': currentVisits,
      'percentChange': percentChange,
      'timestamp': Timestamp.fromDate(timestamp),
      'acknowledgedAt': acknowledgedAt == null
          ? null
          : Timestamp.fromDate(acknowledgedAt!),
      'status': status,
    };
  }
}
