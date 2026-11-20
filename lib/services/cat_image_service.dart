
import 'dart:io';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

//////////////////////////////////////////CAT IMAGE SERVICE//////////////////////////////////////////
class CatImageService {

  static final FirebaseStorage _storage =
      FirebaseStorage.instance;


  //////////////////////////////////////////CURRENT USER//////////////////////////////////////////
  static User get _currentUser {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User must be logged in.');
    }

    return user;
  }


  //////////////////////////////////////////IMAGE REFERENCE//////////////////////////////////////////
  static Reference _imageReference(String catId) {

    return _storage
        .ref()
        .child('users')
        .child(_currentUser.uid)
        .child('cats')
        .child(catId)
        .child('profile.jpg');
  }



//////////////////////////////////////////GET CAT IMAGE URL//////////////////////////////////////////
static Future<String> getCatImageUrl(String catId) async {

  final imageRef = _imageReference(catId);

  return await imageRef.getDownloadURL();
}



//////////////////////////////////////////UPLOAD CAT IMAGE//////////////////////////////////////////
static Future<String> uploadCatImage({
  required String catId,
  required String imagePath,
}) async {

  final imageRef = _imageReference(catId);
  final imageFile = File(imagePath);

  // CHECK THAT IMAGE EXISTS
  if (!await imageFile.exists()) {
    throw Exception('Selected image does not exist.');
  }

  debugPrint('STARTING IMAGE UPLOAD');
  debugPrint('CAT ID: $catId');
  debugPrint('STORAGE PATH: ${imageRef.fullPath}');
  debugPrint('IMAGE SIZE: ${await imageFile.length()} bytes');

  try {

    // UPLOAD IMAGE
    final uploadTask = imageRef.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final snapshot = await uploadTask.timeout(
      const Duration(seconds: 30),
    );

    debugPrint('IMAGE UPLOAD COMPLETE: ${snapshot.state}');

    // GET DOWNLOAD URL
    final imageUrl = await imageRef.getDownloadURL().timeout(
      const Duration(seconds: 15),
    );

    debugPrint('IMAGE URL RETRIEVED');

    return imageUrl;

  } catch (e) {

    debugPrint('IMAGE UPLOAD ERROR: $e');
    rethrow;
  }
}




  //////////////////////////////////////////DELETE CAT IMAGE//////////////////////////////////////////
  static Future<void> deleteCatImage(String catId) async {

    try {

      await _imageReference(catId).delete();

    } on FirebaseException catch (e) {

      // IGNORE IF NO IMAGE EXISTS
      if (e.code != 'object-not-found') {
        rethrow;
      }
    }
  }
}
