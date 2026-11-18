
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/frequency_alert_model.dart';
import '../models/litter_visit_model.dart';

import '../services/litter_visit_service.dart';

import '../other/firebase_id_formatter.dart';

//////////////////////////////////////////FREQUENCY ALERT SERVICE//////////////////////////////////////////
class FrequencyAlertService {

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ALERT WHEN VISITS CHANGE BY 50% OR MORE
  static const double frequencyThreshold = 50.0;

  // SEVEN-DAY ROLLING BASELINE
  static const int comparisonDays = 7;


  //////////////////////////////////////////CURRENT USER//////////////////////////////////////////
  static User get _currentUser {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user;
  }


  //////////////////////////////////////////CAT DOCUMENT//////////////////////////////////////////
  static DocumentReference<Map<String, dynamic>>
      _catDocument(String catId) {

    return _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('cats')
        .doc(catId);
  }


  //////////////////////////////////////////ACTIVE FREQUENCY ALERTS//////////////////////////////////////////
  static CollectionReference<Map<String, dynamic>>
      _alertsCollection(String catId) {

    return _catDocument(catId)
        .collection('frequency_alerts');
  }


  //////////////////////////////////////////FREQUENCY ALERT HISTORY//////////////////////////////////////////
  static CollectionReference<Map<String, dynamic>>
      _historyCollection(String catId) {

    return _catDocument(catId)
        .collection('frequency_alert_history');
  }


  //////////////////////////////////////////CHECK FREQUENCY HISTORY//////////////////////////////////////////
  static Future<void> checkFrequencyHistory(
    String catId,
  ) async {

    // GET FIRST RECORDED VISIT
    final firstVisitSnapshot = await _catDocument(catId)
        .collection('litter_visits')
        .orderBy('timestamp')
        .limit(1)
        .get();

    if (firstVisitSnapshot.docs.isEmpty) {
      return;
    }

    final firstVisit =
        LitterVisit.fromFirestore(firstVisitSnapshot.docs.first);

    final now = DateTime.now();

    // ONLY EVALUATE COMPLETED DAYS
    final lastCompleteDay = DateTime(
      now.year,
      now.month,
      now.day - 1,
    );

    final firstVisitDate = firstVisit.timestamp.toLocal();

    final firstDay = DateTime(
      firstVisitDate.year,
      firstVisitDate.month,
      firstVisitDate.day,
    );

    // GET DAILY VISIT COUNTS
    final dailyVisits =
        await LitterVisitService.getVisitHistory(
      catId: catId,
      startDate: firstDay,
      endDate: lastCompleteDay,
    );

    // REQUIRE SEVEN BASELINE DAYS AND ONE EVALUATION DAY
    if (dailyVisits.length <= comparisonDays) {
      return;
    }

    String? previousAlertType;

    // CHECK EACH DAY AGAINST PREVIOUS SEVEN DAYS
    for (int i = comparisonDays;
        i < dailyVisits.length;
        i++) {

      final current = dailyVisits[i];

      // CALCULATE BASELINE
      double total = 0;

      for (int j = i - comparisonDays; j < i; j++) {
        total += dailyVisits[j].visitCount;
      }

      final averageVisits = total / comparisonDays;

      // A ZERO BASELINE CANNOT PRODUCE A PERCENT CHANGE
      if (averageVisits == 0) {
        previousAlertType = null;
        continue;
      }

      // CALCULATE PERCENTAGE CHANGE
      final percentChange =
          ((current.visitCount - averageVisits) /
              averageVisits) * 100;

      String? alertType;

      if (percentChange >= frequencyThreshold) {
        alertType = 'increase';
      } else if (percentChange <= -frequencyThreshold) {
        alertType = 'decrease';
      }

      // RESET WHEN ACTIVITY RETURNS TO NORMAL
      if (alertType == null) {
        previousAlertType = null;
        continue;
      }

      // AVOID REPEATING THE SAME CONTINUOUS TREND
      if (alertType == previousAlertType) {
        continue;
      }

      previousAlertType = alertType;

      // GENERATE ALERT DOCUMENT ID
      final alertId = FirebaseIdFormatter.frequencyAlert(
        type: alertType,
        timestamp: current.date,
      );

      await _createFrequencyAlert(
        catId: catId,
        alertId: alertId,
        type: alertType,
        averageVisits: averageVisits,
        currentVisits: current.visitCount,
        percentChange: percentChange,
        timestamp: current.date,
      );
    }
  }


  //////////////////////////////////////////CREATE FREQUENCY ALERT//////////////////////////////////////////
  static Future<void> _createFrequencyAlert({
    required String catId,
    required String alertId,
    required String type,
    required double averageVisits,
    required int currentVisits,
    required double percentChange,
    required DateTime timestamp,
  }) async {

    final alertRef = _alertsCollection(catId).doc(alertId);

    // CHECK IF ALERT HAS ALREADY BEEN ACKNOWLEDGED
    final historySnapshot = await _historyCollection(catId)
        .where('sourceAlertId', isEqualTo: alertId)
        .limit(1)
        .get();

    if (historySnapshot.docs.isNotEmpty) {
      return;
    }

    // CREATE ALERT ONLY IF IT DOES NOT ALREADY EXIST
    await _firestore.runTransaction((transaction) async {

      final activeSnapshot =
          await transaction.get(alertRef);

      if (activeSnapshot.exists) {
        return;
      }

      final alert = FrequencyAlert(
        id: alertId,
        catId: catId,
        type: type,
        averageVisits: averageVisits,
        currentVisits: currentVisits,
        percentChange: percentChange,
        timestamp: timestamp,
        status: 'active',
      );

      transaction.set(
        alertRef,
        alert.toFirestore(),
      );
    });
  }


  //////////////////////////////////////////GET ACTIVE FREQUENCY ALERTS//////////////////////////////////////////
  static Future<List<FrequencyAlert>> getAlerts(
    String catId,
  ) async {

    final snapshot = await _alertsCollection(catId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map(FrequencyAlert.fromFirestore)
        .toList();
  }


  //////////////////////////////////////////WATCH ACTIVE FREQUENCY ALERTS//////////////////////////////////////////
  static Stream<List<FrequencyAlert>> watchAlerts(
    String catId,
  ) {

    return _alertsCollection(catId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {

      return snapshot.docs
          .map(FrequencyAlert.fromFirestore)
          .toList();
    });
  }


  //////////////////////////////////////////ACKNOWLEDGE FREQUENCY ALERT//////////////////////////////////////////
  static Future<void> acknowledgeAlert({
    required String catId,
    required String alertId,
  }) async {

    final alertRef =
        _alertsCollection(catId).doc(alertId);

    final acknowledgedAt = DateTime.now();

    // MOVE ALERT TO HISTORY IN ONE TRANSACTION
    await _firestore.runTransaction((transaction) async {

      final alertSnapshot =
          await transaction.get(alertRef);

      // ALREADY ACKNOWLEDGED
      if (!alertSnapshot.exists) {
        return;
      }

      final alertData = alertSnapshot.data()!;

      // GENERATE HISTORY DOCUMENT ID
      final historyId =
          FirebaseIdFormatter.frequencyAlertHistory(
        type: alertData['type'] as String,
        acknowledgedAt: acknowledgedAt,
      );

      final historyRef =
          _historyCollection(catId).doc(historyId);

      // PREVENT OVERWRITING EXISTING HISTORY
      final historySnapshot =
          await transaction.get(historyRef);

      if (historySnapshot.exists) {
        throw Exception(
          'Frequency alert history ID already exists.',
        );
      }

      // MOVE ALERT TO HISTORY
      transaction.set(historyRef, {
        ...alertData,
        'sourceAlertId': alertId,
        'status': 'acknowledged',
        'acknowledgedAt': Timestamp.fromDate(acknowledgedAt),
      });

      transaction.delete(alertRef);
    });
  }


  //////////////////////////////////////////GET FREQUENCY ALERT HISTORY//////////////////////////////////////////
  static Future<List<FrequencyAlert>> getAlertHistory(
    String catId,
  ) async {

    final snapshot = await _historyCollection(catId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map(FrequencyAlert.fromFirestore)
        .toList();
  }


  //////////////////////////////////////////WATCH FREQUENCY ALERT HISTORY//////////////////////////////////////////
  static Stream<List<FrequencyAlert>> watchAlertHistory(
    String catId,
  ) {

    return _historyCollection(catId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {

      return snapshot.docs
          .map(FrequencyAlert.fromFirestore)
          .toList();
    });
  }
}
