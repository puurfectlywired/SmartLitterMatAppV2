
import 'package:flutter/material.dart';

import '../../models/cat_profile.dart';
import 'new_profile.dart';


/////////////////////////////////////////////EDIT PROFILE PAGE STATE//////////////////////////////////////////
class EditProfilePage extends StatelessWidget {
  final CatProfile cat;

  const EditProfilePage({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    return NewProfilePage(
      cat: cat,
      title: 'Edit Profile',
      buttonText: 'Confirm',
      );
  }
}
