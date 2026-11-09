
import 'package:cloud_firestore/cloud_firestore.dart';

//////////////////////////////////////////CAT REPORT MODEL//////////////////////////////////////////
class CatReportData {

  // WEIGHT DATA
  final double? startingWeight;
  final double? endingWeight;

  // LITTER BOX ACTIVITY
  final int? totalVisits;
  final double? averageVisitsPerDay;
  final int? highestDailyVisits;

  // WEIGHT AND FREQUENCY ALERTS ONLY
  final List<CatReportAlert> alerts;

  const CatReportData({
    this.startingWeight,
    this.endingWeight,
    this.totalVisits,
    this.averageVisitsPerDay,
    this.highestDailyVisits,
    this.alerts = const [],
  });

  // CALCULATE WEIGHT CHANGE
  double? get weightChange {
    if (startingWeight == null || endingWeight == null) {
      return null;
    }

    return endingWeight! - startingWeight!;
  }

  //////////////////////////////////////////CONVERT TO FIRESTORE//////////////////////////////////////////
  Map<String, dynamic> toMap() {
    return {
      'startingWeight': startingWeight,
      'endingWeight': endingWeight,
      'totalVisits': totalVisits,
      'averageVisitsPerDay': averageVisitsPerDay,
      'highestDailyVisits': highestDailyVisits,
      'alerts': alerts.map((alert) => alert.toMap()).toList(),
    };
  }

  //////////////////////////////////////////LOAD FROM FIRESTORE//////////////////////////////////////////
  factory CatReportData.fromMap(Map<String, dynamic> data) {
    return CatReportData(
      startingWeight:
          (data['startingWeight'] as num?)?.toDouble(),
      endingWeight:
          (data['endingWeight'] as num?)?.toDouble(),
      totalVisits:
          (data['totalVisits'] as num?)?.toInt(),
      averageVisitsPerDay:
          (data['averageVisitsPerDay'] as num?)?.toDouble(),
      highestDailyVisits:
          (data['highestDailyVisits'] as num?)?.toInt(),
      alerts: (data['alerts'] as List<dynamic>? ?? [])
          .map((item) => CatReportAlert.fromMap(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );
  }
}


//////////////////////////////////////////CAT REPORT ALERT TYPE//////////////////////////////////////////
enum CatReportAlertType {
  weight,
  frequency,
}


//////////////////////////////////////////CAT REPORT ALERT//////////////////////////////////////////
class CatReportAlert {

  final String id;
  final CatReportAlertType type;
  final String title;
  final DateTime timestamp;

  const CatReportAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory CatReportAlert.fromMap(Map<String, dynamic> data) {
    final typeName = data['type'] as String? ?? '';

    // ONLY WEIGHT AND FREQUENCY ALERTS ARE SUPPORTED
    if (typeName != 'weight' && typeName != 'frequency') {
      throw FormatException('Unsupported report alert: $typeName');
    }

    return CatReportAlert(
      id: data['id'] as String? ?? '',
      type: CatReportAlertType.values.byName(typeName),
      title: data['title'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}


//////////////////////////////////////////SAVED CAT REPORT//////////////////////////////////////////
class SavedCatReport {

  final String id;
  final String catId;

  // PROFILE SNAPSHOT
  final String catName;
  final String breed;
  final String sex;
  final String ageLabel;

  // REPORT DATES
  final DateTime startDate;
  final DateTime endDate;
  final DateTime generatedAt;

  // REPORT DATA SNAPSHOT
  final CatReportData reportData;

  const SavedCatReport({
    required this.id,
    required this.catId,
    required this.catName,
    required this.breed,
    required this.sex,
    required this.ageLabel,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.reportData,
  });

  //////////////////////////////////////////CONVERT TO FIRESTORE//////////////////////////////////////////
  Map<String, dynamic> toMap() {
    return {
      'catId': catId,
      'catName': catName,
      'breed': breed,
      'sex': sex,
      'ageLabel': ageLabel,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'generatedAt': Timestamp.fromDate(generatedAt),
      'reportData': reportData.toMap(),
    };
  }

  //////////////////////////////////////////LOAD FROM FIRESTORE//////////////////////////////////////////
  factory SavedCatReport.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return SavedCatReport(
      id: id,
      catId: data['catId'] as String,
      catName: data['catName'] as String,
      breed: data['breed'] as String,
      sex: data['sex'] as String,
      ageLabel: data['ageLabel'] as String,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      generatedAt: (data['generatedAt'] as Timestamp).toDate(),
      reportData: CatReportData.fromMap(
        Map<String, dynamic>.from(data['reportData'] as Map),
      ),
    );
  }
}