
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

//models
import '../models/cat_profile_model.dart';

//services
import '../services/cat_image_service.dart';


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
        birthday: DateTime.parse(data['birthday'] as String),
        breed: data['breed'] as String? ?? '',
        sex: data['sex'] as String? ?? '',
        weight: (data['weight'] as num?)?.toDouble() ?? 0.0,
        imagePath: data['imagePath'] as String?,
      );

    }).toList();
  }


  ///////////////////////////////////////////ADD CAT PROFILE///////////////////////////////////////////
  static Future<void> addProfile(CatProfile cat) async {

    final catId = cat.name.trim();

    String? imageUrl;

    // UPLOAD IMAGE TO FIREBASE STORAGE
    if (cat.imagePath != null && cat.imagePath!.isNotEmpty) {

      debugPrint('UPLOADING IMAGE FOR: $catId');

      imageUrl = await CatImageService.uploadCatImage(
        catId: catId,
        imagePath: cat.imagePath!,
      );

      debugPrint('IMAGE UPLOADED SUCCESSFULLY');

    } else {

      debugPrint('NO IMAGE PATH PROVIDED FOR: $catId');
    }

    // SAVE CAT PROFILE TO FIRESTORE
    await _cats.doc(catId).set({
      'name': cat.name,
      'birthday': cat.birthday.toIso8601String(),
      'breed': cat.breed,
      'sex': cat.sex,
      'weight': cat.weight,
      'imagePath': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint('CAT PROFILE SAVED TO FIRESTORE');
  }




  ///////////////////////////////////////////UPDATE CAT PROFILE///////////////////////////////////////////
  static Future<void> updateProfile(CatProfile cat) async {

    //UPDATE EXISTING CAT DOCUMENT
    await _cats.doc(cat.id).update({
      'name': cat.name,
      'birthday': cat.birthday.toIso8601String(),
      'breed': cat.breed,
      'sex': cat.sex,
      'weight': cat.weight,
      'imagePath': cat.imagePath,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }


  ///////////////////////////////////////////DELETE CAT PROFILE///////////////////////////////////////////
  static Future<void> deleteProfile(String id) async {

    // DELETE CAT IMAGE FROM FIREBASE STORAGE
    await CatImageService.deleteCatImage(id);

    // DELETE CAT DOCUMENT FROM FIRESTORE
    await _cats.doc(id).delete();
  }

}
