
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// //temporary? all alerts will be in the user profile in future\
// import 'dart:async';

import '../models/ammonia_model.dart';



//////////////////////////////////////////AMMONIA SERVICE//////////////////////////////////////////
class AmmoniaService {

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String deviceId = 'mat001';


  //////////////////////////////////////////ACTIVE ALERT COLLECTION//////////////////////////////////////////
  static CollectionReference<Map<String, dynamic>>
      get _alertsCollection {

    // CURRENT FIREBASE USER
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    // USER'S ACTIVE AMMONIA ALERTS
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('active_alerts');
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
  // this is the real one (?) that will be used when all alerts are associated with users
  // static Stream<List<AmmoniaAlert>> watchAlerts() {

  //   return _alertsCollection
  //       .orderBy('created_at', descending: true)
  //       .snapshots()
  //       .map((snapshot) {

  //         return snapshot.docs
  //             .map((doc) => AmmoniaAlert.fromFirestore(doc))
  //             .toList();
  //       });
  // }


  //////////////////////////////////////////LISTEN FOR ACTIVE ALERTS//////////////////////////////////////////
  // static Stream<List<AmmoniaAlert>> watchAlerts() {

  //   final user = FirebaseAuth.instance.currentUser;

  //   if (user == null) {
  //     return Stream.error(
  //       Exception('User is not logged in.'),
  //     );
  //   }

  //   final controller =
  //       StreamController<List<AmmoniaAlert>>();

  //   List<AmmoniaAlert> allAlerts = [];
  //   Set<String> cleanedIds = {};

  //   bool alertsLoaded = false;
  //   bool historyLoaded = false;

  //   void updateAlerts() {

  //     if (!alertsLoaded || !historyLoaded) return;

  //     final activeAlerts = allAlerts
  //         .where((alert) => !cleanedIds.contains(alert.id))
  //         .toList();

  //     if (!controller.isClosed) {
  //       controller.add(activeAlerts);
  //     }
  //   }

  //   final alertSubscription = _alertsCollection
  //       .orderBy('created_at', descending: true)
  //       .snapshots()
  //       .listen(
  //         (snapshot) {

  //           allAlerts = snapshot.docs
  //               .map((doc) => AmmoniaAlert.fromFirestore(doc))
  //               .toList();

  //           alertsLoaded = true;
  //           updateAlerts();
  //         },
  //         onError: controller.addError,
  //       );

  //   final historySubscription = _firestore
  //       .collection('users')
  //       .doc(user.uid)
  //       .collection('alert_history')
  //       .snapshots()
  //       .listen(
  //         (snapshot) {

  //           cleanedIds = snapshot.docs
  //               .map((doc) => doc.id)
  //               .toSet();

  //           historyLoaded = true;
  //           updateAlerts();
  //         },
  //         onError: controller.addError,
  //       );

  //   controller.onCancel = () async {
  //     await alertSubscription.cancel();
  //     await historySubscription.cancel();
  //   };

  //   return controller.stream;
  // }






  //////////////////////////////////////////LISTEN FOR ACTIVE ALERTS//////////////////////////////////////////
  static Stream<List<AmmoniaAlert>> watchAlerts() {

    // CURRENT FIREBASE USER
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.error(
        Exception('User is not logged in.'),
      );
    }

    // LISTEN TO USER'S ACTIVE ALERTS
    return _alertsCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {

          return snapshot.docs
              .map((doc) => AmmoniaAlert.fromFirestore(doc))
              .toList();
        });
  }













  //////////////////////////////////////////REQUEST AMMONIA CALIBRATION//////////////////////////////////////////
  static Future<String> requestAmmoniaCalibration() async {

    // CREATE A NEW AMMONIA COMMAND DOCUMENT
    final commandRef = _firestore
        .collection('device_commands')
        .doc(deviceId)
        .collection('ammonia_commands')
        .doc();

    // SEND COMMAND TO RASPBERRY PI
    await commandRef.set({
      'command': 'litter_cleaned',
      'status': 'pending',
    });

    return commandRef.id;
  }


  //////////////////////////////////////////MOVE ALERT TO HISTORY//////////////////////////////////////////
  static Future<void> moveAlertToCleanHistory(String alertId) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    // ORIGINAL ACTIVE ALERT
    final alertRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('active_alerts')
        .doc(alertId);

    // USER'S ALERT HISTORY
    final historyRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('alert_history')
        .doc(alertId);

    // MOVE ALERT USING A TRANSACTION
    await _firestore.runTransaction((transaction) async {

      final alertSnapshot = await transaction.get(alertRef);
      final historySnapshot = await transaction.get(historyRef);

      // PREVENT DUPLICATE HISTORY ENTRIES
      if (historySnapshot.exists) {

        if (alertSnapshot.exists) {
          transaction.delete(alertRef);
        }

        return;
      }

      if (!alertSnapshot.exists) {
        throw Exception('Alert no longer exists.');
      }

      final alertData = alertSnapshot.data()!;

      // SAVE ALERT TO HISTORY
      transaction.set(historyRef, {
        ...alertData,
        'status': 'cleaned',
        'cleaned_at': FieldValue.serverTimestamp(),
      });

      // REMOVE ORIGINAL ACTIVE ALERT
      transaction.delete(alertRef);
    });
  }





  //////////////////////////////////////////WATCH USER CLEAN ALERT HISTORY//////////////////////////////////////////
  static Stream<List<AmmoniaAlert>> watchCleanAlertHistory() {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.error(
        Exception('User is not logged in.'),
      );
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('alert_history')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {

          return snapshot.docs
              .map((doc) => AmmoniaAlert.fromFirestore(doc))
              .toList();
        });
  }


}