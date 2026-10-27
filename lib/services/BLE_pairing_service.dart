
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

//////////////////////////////////////////BLE PAIRING SERVICE//////////////////////////////////////////
class BlePairingService {

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String deviceId = 'mat001';

  // CURRENT FIREBASE USER
  static User get _currentUser {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user;
  }

  // GENERATE UNIQUE REQUEST ID
  static String _newRequestId() {
    return _firestore
        .collection('device_commands')
        .doc()
        .id;
  }


  // SEND SCAN COMMAND TO RASPBERRY PI
  static Future<String> requestScan({
    required String catId,
    required String catName,
    required String deviceId,
  }) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final requestId = _firestore
        .collection('device_commands')
        .doc()
        .id;

    await _firestore
        .collection('device_commands')
        .doc(deviceId)
        .update({
          'command': 'scan',
          'request_id': requestId,
          'status': 'pending',
          'cat_id': catId,
        });

    debugPrint('BLE SCAN REQUEST SENT: $requestId');

    return requestId;
  }




  // CONFIRM BEACON ASSIGNMENT ON RASPBERRY PI
  static Future<String> requestPair({
    required String catId,
    required String catName,
    required String deviceId,
    required String tagId,
  }) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final requestId = _firestore
        .collection('device_commands')
        .doc()
        .id;

    await _firestore
        .collection('device_commands')
        .doc(deviceId)
        .update({
          'command': 'confirm',
          'request_id': requestId,
          'status': 'pending',
          'cat': catName.trim().toLowerCase(),
          'cat_id': catId,
        });

    debugPrint('BLE CONFIRM REQUEST SENT: $requestId');

    return requestId;
  }




  // CANCEL PAIRING
  static Future<String> requestCancel({
    required String deviceId,
  }) async {

    final requestId = _newRequestId();

      await _firestore
      .collection('device_commands')
      .doc(deviceId)
      .update({
        'command': 'cancel',
        'request_id': requestId,
        'status': 'pending',
      });

    return requestId;
  }


  // REQUEST EXISTING PI ASSIGNMENTS
  static Future<String> requestList({
    required String deviceId,
  }) async {

    // GENERATE UNIQUE REQUEST ID
    final requestId = _newRequestId();

    // SEND LIST COMMAND TO RASPBERRY PI
    await _firestore
        .collection('device_commands')
        .doc(deviceId)
        .update({
          'command': 'list',
          'request_id': requestId,
          'status': 'pending',
        });

    debugPrint('BLE LIST REQUEST SENT: $requestId');

    return requestId;
  }

  // LISTEN FOR RESPONSE FROM RASPBERRY PI
  static Stream<DocumentSnapshot<Map<String, dynamic>>>
      watchRequest({
    required String requestId,
    required String deviceId,
  }) {

    return _firestore
        .collection('device_commands')
        .doc(deviceId)
        .snapshots()
        .where((snapshot) =>
            snapshot.data()?['request_id'] == requestId);
  }

  // SAVE CONFIRMED BEACON TO CAT PROFILE
  static Future<void> savePairedTag({
    required String catId,
    required String deviceId,
    required String tagId,
  }) async {

    final user = _currentUser;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cats')
        .doc(catId)
        .update({
          'ble_mac': tagId.toUpperCase(),
          'ble_device_id': deviceId,
          'ble_status': 'paired',
          'ble_paired_at': FieldValue.serverTimestamp(),
        });

    debugPrint('BLE TAG SAVED TO CAT PROFILE');
  }

  // REMOVE BLE PAIRING FROM CAT PROFILE
  static Future<void> unpairTag({
    required String catId,
  }) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cats')
        .doc(catId)
        .update({
          'ble_mac': FieldValue.delete(),
          'ble_device_id': FieldValue.delete(),
          'ble_status': 'unpaired',
          'ble_paired_at': FieldValue.delete(),
        });

    debugPrint('BLE TAG REMOVED FROM CAT PROFILE');
  }

}