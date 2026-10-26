
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


////////////////////////////////////AUTH SERVICE////////////////////////////////////
class AuthService {

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;


  // REGISTER NEW USER
  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {

    // CREATE USER ACCOUNT IN FIREBASE AUTHENTICATION
    final credential =
        await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // GET USER UID FROM FIREBASE
    final uid = credential.user!.uid;

    // SAVE USER INFORMATION TO FIRESTORE
    await db.collection('users').doc(uid).set({
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': email.trim(),
      'username': username.trim(),
      'usernameLowercase': username.trim().toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }


  // LOGIN EXISTING USER
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {

    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }


  // LOG OUT USER
  Future<void> logoutUser() async {
    await auth.signOut();
  }
}
