import 'package:cloud_firestore/cloud_firestore.dart';

//////////////////////////////////////////WEIGHT MEASUREMENT MODEL//////////////////////////////////////////
class WeightMeasurement {

  final String id;
  final double weight;
  final DateTime timestamp;

  const WeightMeasurement({
    required this.id,
    required this.weight,
    required this.timestamp,
  });


  //////////////////////////////////////////FROM FIRESTORE//////////////////////////////////////////
  factory WeightMeasurement.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {

    final data = doc.data()!;

    return WeightMeasurement(
      id: doc.id,
      weight: (data['weight'] as num).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }


  //////////////////////////////////////////TO FIRESTORE//////////////////////////////////////////
  Map<String, dynamic> toFirestore() {

    return {
      'weight': weight,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}