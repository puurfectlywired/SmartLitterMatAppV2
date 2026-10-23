
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';


//////////////////////////////////////////
class BlePairingService {

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;


  //TEST FIREBASE CONNECTION
  static Future<Map<String, dynamic>> testFirebaseConnection() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    // READ EXISTING RASPBERRY PI COMMAND DOCUMENT
    final document = await _firestore
        .collection('device_commands')
        .doc('mat001')
        .get(const GetOptions(source: Source.server));    //retrieves document from firebase

    if (!document.exists) {
      throw Exception('Mat001 document does not exist.');
    }

    final data = document.data()!;

    debugPrint('FIREBASE CONNECTION SUCCESSFUL');
    debugPrint('COMMAND: ${data['command']}');
    debugPrint('STATUS: ${data['status']}');
    debugPrint('REQUEST ID: ${data['request_id']}');

    return data;
  }


  // SEND SCAN COMMAND TO FIREBASE
  static Future<String> requestScan({
    required String catId,
    required String deviceId,
  }) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    // GENERATE A UNIQUE REQUEST ID
    final requestId = FirebaseFirestore.instance
        .collection('device_commands')
        .doc()
        .id;

    // SEND SCAN COMMAND TO THE RASPBERRY PI
    await _firestore
        .collection('device_commands')
        .doc(deviceId)
        .update({
          'command': 'scan',
          'request_id': requestId,
          'status': 'pending',
          'cat_id': catId,
        });

    return requestId;
  }


  // LISTEN FOR RASPBERRY PI RESPONSE
  static Stream<DocumentSnapshot<Map<String, dynamic>>>
      watchRequest(String requestId) {

    return _firestore
        .collection('device_commands')
        .doc('mat001')
        .snapshots()
        .where((snapshot) {
          return snapshot.data()?['request_id'] == requestId;
        });
  }

}