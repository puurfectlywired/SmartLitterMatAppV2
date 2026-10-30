
import 'package:cloud_firestore/cloud_firestore.dart';

//////////////////////////////////////////AMMONIA ALERT MODEL//////////////////////////////////////////
class AmmoniaAlert {

  final String id;
  final String type;
  final String deviceId;
  final double? percentIncrease;
  final String status;
  final DateTime timestamp;
  final DateTime? readingAt;

  const AmmoniaAlert({
    required this.id,
    required this.type,
    required this.deviceId,
    required this.percentIncrease,
    required this.status,
    required this.timestamp,
    required this.readingAt,
  });

  ////////////////////////////////////////////CONVERT FIREBASE DATE//////////////////////////////////////////
  static DateTime? _parseDate(dynamic value) {

    // FIRESTORE TIMESTAMP
    if (value is Timestamp) {
      return value.toDate();
    }

    // STRING DATE
    if (value is String) {
      return DateTime.tryParse(value);
    }

    // DART DATETIME
    if (value is DateTime) {
      return value;
    }

    return null;
  }

  ////////////////////////////////////////////CREATE FROM FIREBASE//////////////////////////////////////////
  factory AmmoniaAlert.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {

    final data = doc.data() ?? {};

    return AmmoniaAlert(
      id: doc.id,

      type: data['type'] as String? ??
          'ammonia_elevated',

      deviceId: data['device_id'] as String? ?? '',

      percentIncrease:
          (data['percent_increase'] as num?)?.toDouble(),

      status: data['status'] as String? ?? 'new',

      timestamp:
          _parseDate(data['created_at']) ??
          DateTime.now(),

      readingAt:
          _parseDate(data['reading_at']),
    );
  }
}