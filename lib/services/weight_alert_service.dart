//change later so it reads average weights instead on individual weights?



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/weight_alert_model.dart';
import '../models/weight_measurement_model.dart';

//////////////////////////////////////////WEIGHT ALERT SERVICE//////////////////////////////////////////
class WeightAlertService {

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // WEIGHTS ARE STORED IN POUNDS
  static const double weightThreshold = 1.0;

  // COMPARE MEASUREMENTS APPROXIMATELY ONE WEEK APART
  static const int comparisonDays = 7;
  static const int toleranceDays = 1;


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


  //////////////////////////////////////////WEIGHT MEASUREMENTS//////////////////////////////////////////
  static CollectionReference<Map<String, dynamic>>
      _weightCollection(String catId) {

    return _catDocument(catId)
        .collection('weight_measurements');
  }


  //////////////////////////////////////////ACTIVE WEIGHT ALERTS//////////////////////////////////////////
  static CollectionReference<Map<String, dynamic>>
      _alertsCollection(String catId) {

    return _catDocument(catId)
        .collection('weight_alerts');
  }


  //////////////////////////////////////////WEIGHT ALERT HISTORY//////////////////////////////////////////
  static CollectionReference<Map<String, dynamic>>
      _historyCollection(String catId) {

    return _catDocument(catId)
        .collection('weight_alert_history');
  }


  //////////////////////////////////////////CHECK WEIGHT HISTORY//////////////////////////////////////////
  static Future<void> checkWeightHistory(String catId) async {

    // GET ALL WEIGHT MEASUREMENTS
    final snapshot = await _weightCollection(catId)
        .orderBy('timestamp')
        .get();

    if (snapshot.docs.length < 2) {
      return;
    }

    final measurements = snapshot.docs
        .map(WeightMeasurement.fromFirestore)
        .toList();

    // TRACK THE PREVIOUS ALERT DIRECTION
    String? previousAlertType;

    // CHECK EACH MEASUREMENT IN CHRONOLOGICAL ORDER
    for (int i = 1; i < measurements.length; i++) {

      final current = measurements[i];

      WeightMeasurement? previous;

      Duration? closestDifference;

      // FIND MEASUREMENT CLOSEST TO SEVEN DAYS EARLIER
      for (int j = 0; j < i; j++) {

        final candidate = measurements[j];

        final elapsed = current.timestamp.difference(
          candidate.timestamp,
        );

        final days = elapsed.inMinutes / (60 * 24);

        if (days < comparisonDays - toleranceDays ||
            days > comparisonDays + toleranceDays) {
          continue;
        }

        final difference = Duration(
          milliseconds: (
            elapsed.inMilliseconds -
            const Duration(days: comparisonDays)
                .inMilliseconds
          ).abs(),
        );

        if (closestDifference == null ||
            difference < closestDifference) {

          previous = candidate;
          closestDifference = difference;
        }
      }

      if (previous == null) {
        continue;
      }

      // CALCULATE WEIGHT CHANGE
      final weightChange =
          current.weight - previous.weight;

      // DETERMINE ALERT TYPE
      String? alertType;

      if (weightChange >= weightThreshold - 0.000001) {
        alertType = 'gain';
      } else if (weightChange <= -weightThreshold + 0.000001) {
        alertType = 'loss';
      }

      // RESET WHEN WEIGHT CHANGE RETURNS BELOW THRESHOLD
      if (alertType == null) {
        previousAlertType = null;
        continue;
      }

      // AVOID REPEATING THE SAME CONTINUOUS TREND
      if (alertType == previousAlertType) {
        continue;
      }

      previousAlertType = alertType;

      // CREATE A STABLE ID FOR THIS DETECTED EVENT
      final alertId = '${current.id}_${alertType}';

      await _createWeightAlert(
        catId: catId,
        alertId: alertId,
        type: alertType,
        previousWeight: previous.weight,
        currentWeight: current.weight,
        weightChange: weightChange,
        timestamp: current.timestamp,
      );
    }
  }


  //////////////////////////////////////////CREATE WEIGHT ALERT//////////////////////////////////////////
  static Future<void> _createWeightAlert({
    required String catId,
    required String alertId,
    required String type,
    required double previousWeight,
    required double currentWeight,
    required double weightChange,
    required DateTime timestamp,
  }) async {

    final alertRef = _alertsCollection(catId).doc(alertId);

    final historyRef = _historyCollection(catId).doc(alertId);

    // PREVENT DUPLICATES IN ACTIVE ALERTS AND HISTORY
    await _firestore.runTransaction((transaction) async {

      final activeSnapshot =
          await transaction.get(alertRef);

      final historySnapshot =
          await transaction.get(historyRef);

      if (activeSnapshot.exists || historySnapshot.exists) {
        return;
      }

      final alert = WeightAlert(
        id: alertId,
        catId: catId,
        type: type,
        previousWeight: previousWeight,
        currentWeight: currentWeight,
        weightChange: weightChange,
        timestamp: timestamp,
        status: 'active',
      );

      transaction.set(
        alertRef,
        alert.toFirestore(),
      );
    });
  }


  //////////////////////////////////////////GET ACTIVE WEIGHT ALERTS//////////////////////////////////////////
  static Future<List<WeightAlert>> getAlerts(
    String catId,
  ) async {

    final snapshot = await _alertsCollection(catId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map(WeightAlert.fromFirestore)
        .toList();
  }


  //////////////////////////////////////////WATCH ACTIVE WEIGHT ALERTS//////////////////////////////////////////
  static Stream<List<WeightAlert>> watchAlerts(
    String catId,
  ) {

    return _alertsCollection(catId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {

          return snapshot.docs
              .map(WeightAlert.fromFirestore)
              .toList();
        });
  }


  //////////////////////////////////////////ACKNOWLEDGE WEIGHT ALERT//////////////////////////////////////////
  static Future<void> acknowledgeAlert({
    required String catId,
    required String alertId,
  }) async {

    final alertRef =
        _alertsCollection(catId).doc(alertId);

    final historyRef =
        _historyCollection(catId).doc(alertId);

    // MOVE ALERT TO HISTORY IN ONE TRANSACTION
    await _firestore.runTransaction((transaction) async {

      final alertSnapshot =
          await transaction.get(alertRef);

      final historySnapshot =
          await transaction.get(historyRef);

      // ALREADY ACKNOWLEDGED
      if (historySnapshot.exists) {

        if (alertSnapshot.exists) {
          transaction.delete(alertRef);
        }

        return;
      }

      if (!alertSnapshot.exists) {
        throw Exception('Weight alert no longer exists.');
      }

      final alertData = alertSnapshot.data()!;

      transaction.set(historyRef, {
        ...alertData,
        'status': 'acknowledged',
        'acknowledgedAt': FieldValue.serverTimestamp(),
      });

      transaction.delete(alertRef);
    });
  }


  //////////////////////////////////////////GET WEIGHT ALERT HISTORY//////////////////////////////////////////
  static Future<List<WeightAlert>> getAlertHistory(
    String catId,
  ) async {

    final snapshot = await _historyCollection(catId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map(WeightAlert.fromFirestore)
        .toList();
  }


  //////////////////////////////////////////WATCH WEIGHT ALERT HISTORY//////////////////////////////////////////
  static Stream<List<WeightAlert>> watchAlertHistory(
    String catId,
  ) {

    return _historyCollection(catId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {

          return snapshot.docs
              .map(WeightAlert.fromFirestore)
              .toList();
        });
  }
}
