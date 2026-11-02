
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//////////////////////////////////////////ALERT HISTORY SERVICE//////////////////////////////////////////
class AlertHistoryService {

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // CURRENT USER
  static String get _userId {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  // ALERT COLLECTION
  static CollectionReference<Map<String, dynamic>>
      get _alerts {

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('alerts');
  }

  //////////////////////////////////////////ACTIVE ALERTS//////////////////////////////////////////
  static Stream<QuerySnapshot<Map<String, dynamic>>>
      watchActiveAlerts() {

    return _alerts
        .where('resolved', isEqualTo: false)
        .snapshots();
  }

  //////////////////////////////////////////ALERT HISTORY//////////////////////////////////////////
  static Stream<QuerySnapshot<Map<String, dynamic>>>
      watchAlertHistory() {

    return _alerts
        .where('resolved', isEqualTo: true)
        .snapshots();
  }

  //////////////////////////////////////////RESOLVE ALERT//////////////////////////////////////////
  static Future<void> resolveAlert(String alertId) async {

    await _alerts.doc(alertId).update({
      'resolved': true,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }
}
