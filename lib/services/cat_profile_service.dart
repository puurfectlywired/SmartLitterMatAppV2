
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//models
import '../models/cat_profile_model.dart';


///////////////////////////////////////////CAT PROFILE SERVICE///////////////////////////////////////////
class ProfileService {

  //FIREBASE DATABASE
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  //CURRENTLY LOGGED-IN USER
  static User get _currentUser {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User must be logged in.');
    }

    return user;
  }

  //CAT COLLECTION FOR CURRENT USER
  static CollectionReference<Map<String, dynamic>> get _cats {
    return _db
        .collection('users')
        .doc(_currentUser.uid)
        .collection('cats');
  }


  ///////////////////////////////////////////GET CAT PROFILES///////////////////////////////////////////
  static Future<List<CatProfile>> getProfiles() async {

    //GET CAT DOCUMENTS FROM FIRESTORE
    final snapshot = await _cats.get();

    //CONVERT FIRESTORE DOCUMENTS TO CATPROFILE OBJECTS
    return snapshot.docs.map((doc) {

      final data = doc.data();

      return CatProfile(
        id: doc.id,
        name: data['name'] as String? ?? '',
        age: (data['age'] as num?)?.toInt() ?? 0,
        breed: data['breed'] as String? ?? '',
        sex: data['sex'] as String? ?? '',
        weight: (data['weight'] as num?)?.toDouble() ?? 0.0,
        imagePath: data['imagePath'] as String?,
      );

    }).toList();
  }


  ///////////////////////////////////////////ADD CAT PROFILE///////////////////////////////////////////
  static Future<void> addProfile(CatProfile cat) async {

    //SAVE NEW CAT TO FIRESTORE
    await _cats.doc(cat.id).set({
      'name': cat.name,
      'age': cat.age,
      'breed': cat.breed,
      'sex': cat.sex,
      'weight': cat.weight,
      'imagePath': cat.imagePath,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }


  ///////////////////////////////////////////UPDATE CAT PROFILE///////////////////////////////////////////
  static Future<void> updateProfile(CatProfile cat) async {

    //UPDATE EXISTING CAT DOCUMENT
    await _cats.doc(cat.id).update({
      'name': cat.name,
      'age': cat.age,
      'breed': cat.breed,
      'sex': cat.sex,
      'weight': cat.weight,
      'imagePath': cat.imagePath,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }


  ///////////////////////////////////////////DELETE CAT PROFILE///////////////////////////////////////////
  static Future<void> deleteProfile(String id) async {

    //DELETE CAT DOCUMENT FROM FIRESTORE
    await _cats.doc(id).delete();
  }
}