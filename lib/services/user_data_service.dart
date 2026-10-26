
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_data_model.dart';

////////////////////////////////////USER DATA SERVICE////////////////////////////////////
class UserDataService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GET CURRENT USER DATA
  Future<UserData?> getCurrentUserData() async {

    final user = _auth.currentUser;

    if (user == null) return null;

    final doc = await _db
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;

    return UserData.fromFirestore(
      user.uid,
      doc.data()!,
    );
  }
}
