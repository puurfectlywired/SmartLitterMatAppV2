
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ammonia_model.dart';

//////////////////////////////////////////AMMONIA SERVICE//////////////////////////////////////////
class AmmoniaService {

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String deviceId = 'mat001';

  ////////////////////////////////////////////ALERT COLLECTION//////////////////////////////////////////
  static CollectionReference<Map<String, dynamic>>
      get _alertsCollection {

    return _firestore
        .collection('device_status')
        .doc(deviceId)
        .collection('alerts');
  }

  ////////////////////////////////////////////GET ALL ALERTS//////////////////////////////////////////
  static Future<List<AmmoniaAlert>> getAlerts() async {

    final snapshot = await _alertsCollection
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AmmoniaAlert.fromFirestore(doc))
        .toList();
  }

  ////////////////////////////////////////////LISTEN FOR ALERTS//////////////////////////////////////////
  static Stream<List<AmmoniaAlert>> watchAlerts() {

    return _alertsCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {

          return snapshot.docs
              .map((doc) => AmmoniaAlert.fromFirestore(doc))
              .toList();
        });
  }
}
