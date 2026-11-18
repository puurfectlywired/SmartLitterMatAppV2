import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//models
import '../models/cat_report_model.dart';

//services
import '../services/weight_measurement_service.dart';
import '../services/litter_visit_service.dart';
import '../services/weight_alert_service.dart';

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

    // START OF FIRST SELECTED DAY
    final reportStartDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    // END OF LAST SELECTED DAY
    final reportEndDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day + 1,
    ).subtract(
      const Duration(microseconds: 1),
    );


    //////////////////////////////////////////WEIGHT MEASUREMENTS//////////////////////////////////////////
    final weightMeasurements =
        await WeightService.getWeightHistory(
      catId: catId,
      startDate: reportStartDate,
      endDate: reportEndDate,
    );

    // STARTING WEIGHT
    final double? startingWeight =
        weightMeasurements.isEmpty
            ? null
            : weightMeasurements.first.weight;

    // ENDING WEIGHT
    final double? endingWeight =
        weightMeasurements.isEmpty
            ? null
            : weightMeasurements.last.weight;


    //////////////////////////////////////////LITTER BOX ACTIVITY//////////////////////////////////////////
    final litterVisits =
        await LitterVisitService.getVisitHistory(
      catId: catId,
      startDate: reportStartDate,
      endDate: reportEndDate,
    );

    // TOTAL VISITS
    final int? totalVisits =
        litterVisits.isEmpty
            ? null
            : litterVisits.fold<int>(
                0,
                (total, visit) =>
                    total + visit.visitCount,
              );

    // NUMBER OF DAYS WITH RECORDED VISITS
    final int daysWithVisits = litterVisits
        .where((day) => day.visitCount > 0)
        .length;

    // AVERAGE VISITS PER DAY
    final double? averageVisitsPerDay =
        daysWithVisits == 0
            ? null
            : totalVisits! / daysWithVisits;
 
    // HIGHEST DAILY VISIT COUNT
    final int? highestDailyVisits =
        litterVisits.isEmpty
            ? null
            : litterVisits
                .map((visit) => visit.visitCount)
                .reduce(
                  (a, b) => a > b ? a : b,
                );



  //////////////////////////////////////////HEALTH ALERTS//////////////////////////////////////////
  // LOAD ACTIVE AND ACKNOWLEDGED WEIGHT ALERTS
  final weightAlertResults = await Future.wait([
    WeightAlertService.getAlerts(catId),
    WeightAlertService.getAlertHistory(catId),
  ]);

  final activeWeightAlerts = weightAlertResults[0];
  final acknowledgedWeightAlerts = weightAlertResults[1];

  // COMBINE ALERTS AND PREVENT DUPLICATES BY ID
  final allWeightAlerts = {
    for (final alert in acknowledgedWeightAlerts)
      alert.id: alert,
    for (final alert in activeWeightAlerts)
      alert.id: alert,
  }.values;

  // CONVERT WEIGHT ALERTS TO REPORT ALERTS
  final List<CatReportAlert> reportAlerts = [];

  for (final alert in allWeightAlerts) {

    // ONLY INCLUDE ALERTS WITHIN REPORT DATE RANGE
    if (alert.timestamp.isBefore(reportStartDate) ||
        alert.timestamp.isAfter(reportEndDate)) {
      continue;
    }

    // DETERMINE WEIGHT ALERT TITLE
    final String title;

    if (alert.type == 'gain') {
      title = 'Weight Gain: '
          '+${alert.weightChange.abs().toStringAsFixed(1)} lb';
    } else if (alert.type == 'loss') {
      title = 'Weight Loss: '
          '-${alert.weightChange.abs().toStringAsFixed(1)} lb';
    } else {
      title = 'Weight Change Detected';
    }

    reportAlerts.add(
      CatReportAlert(
        id: alert.id,
        type: CatReportAlertType.weight,
        title: title,
        timestamp: alert.timestamp,
      ),
    );
  }

  // SORT ALERTS BY DATE - NEWEST FIRST
  reportAlerts.sort(
    (a, b) => b.timestamp.compareTo(a.timestamp),
  );


    //////////////////////////////////////////RETURN REPORT DATA//////////////////////////////////////////

    return CatReportData(

      // WEIGHT DATA
      startingWeight: startingWeight,
      endingWeight: endingWeight,

      // LITTER BOX ACTIVITY
      totalVisits: totalVisits,
      averageVisitsPerDay: averageVisitsPerDay,
      highestDailyVisits: highestDailyVisits,

      // WEIGHT AND FREQUENCY ALERTS
      alerts: reportAlerts,

    );
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