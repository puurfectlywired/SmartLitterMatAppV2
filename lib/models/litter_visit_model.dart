import 'package:cloud_firestore/cloud_firestore.dart';

//////////////////////////////////////////LITTER VISIT MODEL//////////////////////////////////////////
class LitterVisit {

  final String id;
  final bool visit;
  final DateTime timestamp;

  const LitterVisit({
    required this.id,
    required this.visit,
    required this.timestamp,
  });


  //////////////////////////////////////////FROM FIRESTORE//////////////////////////////////////////
  factory LitterVisit.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {

    final data = doc.data()!;

    return LitterVisit(
      id: doc.id,
      visit: data['visit'] as bool,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }


  //////////////////////////////////////////TO FIRESTORE//////////////////////////////////////////
  Map<String, dynamic> toFirestore() {

    return {
      'visit': visit,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}


//////////////////////////////////////////DAILY LITTER VISITS MODEL//////////////////////////////////////////
class DailyLitterVisits {

  final DateTime date;
  final int visitCount;

  const DailyLitterVisits({
    required this.date,
    required this.visitCount,
  });
}