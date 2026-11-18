import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/litter_visit_model.dart';

//////////////////////////////////////////LITTER VISIT SERVICE//////////////////////////////////////////
class LitterVisitService {

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;


  //////////////////////////////////////////CURRENT USER//////////////////////////////////////////
  static User get _currentUser {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User must be logged in.');
    }

    return user;
  }


  //////////////////////////////////////////LITTER VISIT COLLECTION//////////////////////////////////////////
  static CollectionReference<Map<String, dynamic>>
      _visitCollection(String catId) {

    return _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('cats')
        .doc(catId)
        .collection('litter_visits');
  }


  //////////////////////////////////////////DATE RANGE QUERY//////////////////////////////////////////
  static Query<Map<String, dynamic>> _dateRangeQuery({
    required String catId,
    required DateTime startDate,
    required DateTime endDate,
  }) {

    // START OF FIRST SELECTED DAY
    final firstDay = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    // START OF DAY AFTER LAST SELECTED DAY
    final lastDayExclusive = DateTime(
      endDate.year,
      endDate.month,
      endDate.day + 1,
    );

    return _visitCollection(catId)

        // INCLUDE FIRST DAY AT MIDNIGHT
        .where(
          'timestamp',
          isGreaterThanOrEqualTo:
              Timestamp.fromDate(firstDay),
        )

        // EXCLUDE MIDNIGHT OF FOLLOWING DAY
        .where(
          'timestamp',
          isLessThan:
              Timestamp.fromDate(lastDayExclusive),
        )

        .orderBy('timestamp');
  }


  //////////////////////////////////////////CALCULATE DAILY VISIT COUNTS//////////////////////////////////////////
  static List<DailyLitterVisits> _calculateDailyVisits({
    required List<LitterVisit> visits,
    required DateTime startDate,
    required DateTime endDate,
  }) {

    // NO RECORDED DATA
    if (visits.isEmpty) {
      return [];
    }

    // MAP OF CALENDAR DATE TO NUMBER OF VISITS
    final Map<DateTime, int> dailyCounts = {};

    // START OF FIRST SELECTED DAY
    final firstDay = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    // START OF LAST SELECTED DAY
    final lastDay = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );


    // INITIALIZE EACH DAY WITH ZERO VISITS
    DateTime currentDay = firstDay;

    while (!currentDay.isAfter(lastDay)) {

      dailyCounts[currentDay] = 0;

      // MOVE TO NEXT CALENDAR DAY
      currentDay = DateTime(
        currentDay.year,
        currentDay.month,
        currentDay.day + 1,
      );
    }


    // COUNT INDIVIDUAL VISITS
    for (final visit in visits) {

      // ONLY COUNT CONFIRMED VISITS
      if (!visit.visit) {
        continue;
      }

      // CONVERT TIMESTAMP TO LOCAL TIME
      final localTimestamp =
          visit.timestamp.toLocal();

      // GET CALENDAR DATE OF VISIT
      final visitDate = DateTime(
        localTimestamp.year,
        localTimestamp.month,
        localTimestamp.day,
      );

      // ADD ONE VISIT TO CORRECT DAY
      if (dailyCounts.containsKey(visitDate)) {

        dailyCounts[visitDate] =
            dailyCounts[visitDate]! + 1;
      }
    }


    // CONVERT DAILY COUNTS INTO MODEL OBJECTS
    return dailyCounts.entries.map((entry) {

      return DailyLitterVisits(
        date: entry.key,
        visitCount: entry.value,
      );

    }).toList();
  }


  //////////////////////////////////////////GET INDIVIDUAL VISIT HISTORY//////////////////////////////////////////
  static Future<List<LitterVisit>>
      getIndividualVisits({
    required String catId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {

    final snapshot = await _dateRangeQuery(
      catId: catId,
      startDate: startDate,
      endDate: endDate,
    ).get();

    return snapshot.docs.map((doc) {

      return LitterVisit.fromFirestore(doc);

    }).toList();
  }


  //////////////////////////////////////////WATCH LATEST VISIT//////////////////////////////////////////
  static Stream<LitterVisit?> watchLatestVisit(
    String catId,
  ) {

    return _visitCollection(catId)

        // MOST RECENT VISITS FIRST
        .orderBy('timestamp', descending: true)

        .snapshots()

        .map((snapshot) {

          // FIND MOST RECENT CONFIRMED VISIT
          for (final doc in snapshot.docs) {

            final visit =
                LitterVisit.fromFirestore(doc);

            if (visit.visit) {

              return visit;
            }
          }

          // NO CONFIRMED VISITS
          return null;

        });
  }

  //////////////////////////////////////////GET DAILY VISIT HISTORY//////////////////////////////////////////
  static Future<List<DailyLitterVisits>>
      getVisitHistory({
    required String catId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {

    // RETRIEVE INDIVIDUAL VISITS
    final visits = await getIndividualVisits(
      catId: catId,
      startDate: startDate,
      endDate: endDate,
    );

    // CALCULATE VISITS PER DAY
    return _calculateDailyVisits(
      visits: visits,
      startDate: startDate,
      endDate: endDate,
    );
  }


  //////////////////////////////////////////WATCH DAILY VISIT HISTORY//////////////////////////////////////////
  static Stream<List<DailyLitterVisits>>
      watchVisitHistory({
    required String catId,
    required DateTime startDate,
    required DateTime endDate,
  }) {

    return _dateRangeQuery(
      catId: catId,
      startDate: startDate,
      endDate: endDate,
    ).snapshots().map((snapshot) {

      // CONVERT FIRESTORE DOCUMENTS INTO VISITS
      final visits = snapshot.docs.map((doc) {

        return LitterVisit.fromFirestore(doc);

      }).toList();

      // CALCULATE VISITS PER DAY
      return _calculateDailyVisits(
        visits: visits,
        startDate: startDate,
        endDate: endDate,
      );

    });
  }


  //////////////////////////////////////////GET TODAY'S VISIT COUNT//////////////////////////////////////////
  static Future<int?> getTodayVisitCount(
    String catId,
  ) async {

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final visits = await getVisitHistory(
      catId: catId,
      startDate: today,
      endDate: today,
    );

    if (visits.isEmpty) {
      return null;
    }

    return visits.first.visitCount;
  }
}