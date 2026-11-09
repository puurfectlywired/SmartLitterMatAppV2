
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cat_report_model.dart';

//////////////////////////////////////////CAT REPORT SERVICE//////////////////////////////////////////
class CatReportService {

  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  //////////////////////////////////////////CURRENT USER//////////////////////////////////////////
  static User get _currentUser {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User must be logged in.');
    }

    return user;
  }

  //////////////////////////////////////////REPORT HISTORY COLLECTION//////////////////////////////////////////
  static CollectionReference<Map<String, dynamic>>
      _reportCollection(String catId) {

    return _db
        .collection('users')
        .doc(_currentUser.uid)
        .collection('cats')
        .doc(catId)
        .collection('report_history');
  }


  //////////////////////////////////////////GET REPORT DATA//////////////////////////////////////////
  static Future<CatReportData> getReportData({
    required String catId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {

    // TODO: LOAD WEIGHT MEASUREMENTS FROM FIRESTORE
    // users/{uid}/cats/{catId}/visits

    // TODO: CALCULATE LITTER BOX ACTIVITY
    // - Total visits
    // - Average visits per day
    // - Highest daily count

    // TODO: LOAD WEIGHT AND FREQUENCY ALERTS
    // Filter by catId, startDate, and endDate.
    // Do not include ammonia alerts.

    return const CatReportData();
  }


  //////////////////////////////////////////SAVE REPORT//////////////////////////////////////////
  static Future<String> saveReport(
    SavedCatReport report,
  ) async {

    // CREATE A NEW DOCUMENT UNDER THE CAT
    final document = _reportCollection(report.catId).doc();

    // SAVE THE COMPLETE REPORT SNAPSHOT
    await document.set(report.toMap());

    return document.id;
  }


  //////////////////////////////////////////WATCH REPORT HISTORY//////////////////////////////////////////
  static Stream<List<SavedCatReport>> watchReportHistory(
    String catId,
  ) {

    return _reportCollection(catId)
        .orderBy('generatedAt', descending: true)
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return SavedCatReport.fromMap(
          doc.id,
          doc.data(),
        );

      }).toList();
    });
  }


  //////////////////////////////////////////GET SAVED REPORT//////////////////////////////////////////
  static Future<SavedCatReport?> getSavedReport({
    required String catId,
    required String reportId,
  }) async {

    final document = await _reportCollection(catId)
        .doc(reportId)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return SavedCatReport.fromMap(
      document.id,
      document.data()!,
    );
  }
}