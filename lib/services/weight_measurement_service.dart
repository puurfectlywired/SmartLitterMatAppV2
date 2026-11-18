import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/weight_measurement_model.dart';

//////////////////////////////////////////WEIGHT SERVICE//////////////////////////////////////////
class WeightService {

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  //////////////////////////////////////////CURRENT USER//////////////////////////////////////////
  static User get _currentUser {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user;
  }

  //////////////////////////////////////////WEIGHT COLLECTION//////////////////////////////////////////
  static CollectionReference<Map<String, dynamic>>
      _weightCollection(String catId) {

    return _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('cats')
        .doc(catId)
        .collection('weight_measurements');
  }

  //////////////////////////////////////////GET LATEST WEIGHT//////////////////////////////////////////
  static Future<WeightMeasurement?> getLatestWeight(
    String catId,
  ) async {

    final snapshot = await _weightCollection(catId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return WeightMeasurement.fromFirestore(
      snapshot.docs.first,
    );
  }

  //////////////////////////////////////////WATCH LATEST WEIGHT//////////////////////////////////////////
  static Stream<WeightMeasurement?> watchLatestWeight(
    String catId,
  ) {

    return _weightCollection(catId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {

          if (snapshot.docs.isEmpty) {
            return null;
          }

          return WeightMeasurement.fromFirestore(
            snapshot.docs.first,
          );
        });
  }

  //////////////////////////////////////////GET WEIGHT HISTORY//////////////////////////////////////////
  static Future<List<WeightMeasurement>> getWeightHistory({
    required String catId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {

    final snapshot = await _weightCollection(catId)
        .where(
          'timestamp',
          isGreaterThanOrEqualTo:
              Timestamp.fromDate(startDate),
        )
        .where(
          'timestamp',
          isLessThanOrEqualTo:
              Timestamp.fromDate(endDate),
        )
        .orderBy('timestamp')
        .get();

    return snapshot.docs
        .map(WeightMeasurement.fromFirestore)
        .toList();
  }

  //////////////////////////////////////////WATCH WEIGHT HISTORY//////////////////////////////////////////
  static Stream<List<WeightMeasurement>> watchWeightHistory({
    required String catId,
    required DateTime startDate,
    required DateTime endDate,
  }) {

    return _weightCollection(catId)
        .where(
          'timestamp',
          isGreaterThanOrEqualTo:
              Timestamp.fromDate(startDate),
        )
        .where(
          'timestamp',
          isLessThanOrEqualTo:
              Timestamp.fromDate(endDate),
        )
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {

          return snapshot.docs
              .map(WeightMeasurement.fromFirestore)
              .toList();
        });
  }
}