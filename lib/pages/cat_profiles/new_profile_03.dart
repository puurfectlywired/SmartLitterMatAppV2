
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import '../../widgets/registration_header.dart';
import '../../theme/app_colours.dart';
import '../../models/cat_registration_model.dart';
import 'new_profile_04.dart';
import '../../services/local_image_service.dart';

////////////////////////////////////////////NEW PROFILE PAGE 03//////////////////////////////////////////
class NewProfilePage03 extends StatefulWidget {
  const NewProfilePage03({
    super.key,
    required this.registration,
  });

  final CatRegistration registration;

  @override
  State<NewProfilePage03> createState() => _NewProfilePage03State();
}

////////////////////////////////////////////NEW PROFILE PAGE STATE//////////////////////////////////////////
class _NewProfilePage03State extends State<NewProfilePage03> {

  File? selectedImage;

  ////////////////////////////////////////////PICK IMAGE//////////////////////////////////////////

////////////////////////////////////////////PICK IMAGE//////////////////////////////////////////
Future<void> _pickImage() async {
  try {
    final ImagePicker picker = ImagePicker();

    // SELECT IMAGE
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    // CROP IMAGE
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: image.path,

      uiSettings: [
        IOSUiSettings(
          title: 'Adjust Photo',
          cropStyle: CropStyle.circle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),

        AndroidUiSettings(
          toolbarTitle: 'Adjust Photo',
          cropStyle: CropStyle.circle,
          lockAspectRatio: true,
          initAspectRatio: CropAspectRatioPreset.square,
        ),
      ],
    );

    if (croppedImage == null || !mounted) return;

    // SAVE IMAGE TO APP'S DOCUMENTS DIRECTORY
    final savedImagePath = await LocalImageService.saveCatImage(
      croppedImage.path,
    );

    if (!mounted) return;

    // UPDATE SELECTED IMAGE
    setState(() {
      selectedImage = File(savedImagePath);
    });

    debugPrint('CAT IMAGE SAVED TO: $savedImagePath');

  } catch (e) {
    debugPrint('IMAGE PICKER ERROR: $e');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not select image.'),
      ),
    );
  }
}


  ////////////////////////////////////////////CONTINUE//////////////////////////////////////////
  void _continue() {

    // SAVE SELECTED IMAGE TO REGISTRATION MODEL
    widget.registration.imagePath = selectedImage?.path;

    // CHECK REQUIRED INFORMATION
    if (widget.registration.name.trim().isEmpty ||
        widget.registration.sex.isEmpty ||
        widget.registration.birthday == null ||
        widget.registration.weight == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some profile information is missing.'),
        ),
      );
      return;
    }

    // NAVIGATE TO PAGE 4
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NewProfilePage04(
              registration: widget.registration,
            ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  ////////////////////////////////////////////BUILD PAGE//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      body: ListView(
        padding: EdgeInsets.zero,
        keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,

        children: [

          // REGISTRATION HEADER
          ColoredBox(
            color: appColors.registrationHeader,
            child: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: ColoredBox(
                color: colorScheme.surface,
                child: const RegistrationHeader(
                  progress: 0.75,
                ),
              ),
            ),
          ),

          // INTRODUCTION
          const Text(
            'Say Cheese!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Time to upload your cat's cutest photo!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 35),

          Text(
            'Choose a PNG or JPG photo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 55),

          // PROFILE PHOTO
          Center(
            child: GestureDetector(
              onTap: _pickImage,

              child: Container(
                width: 220,
                height: 220,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainerHighest,
                ),

                child: ClipOval(
                  child: selectedImage != null

                      // SELECTED PHOTO
                      ? Image.file(
                          selectedImage!,
                          width: 220,
                          height: 220,
                          fit: BoxFit.cover,
                        )

                      // DEFAULT PLACEHOLDER
                      : Icon(
                          Icons.pets,
                          size: 100,
                          color: colorScheme.primary,
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 65),

          
// BUTTONS
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 35),

  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [

      // MAIN BUTTON
      SizedBox(
        height: 55,
        child: ElevatedButton(
          onPressed: selectedImage == null
              ? _pickImage
              : _continue,

          child: Text(
            selectedImage == null
                ? 'Upload Photo'
                : 'Continue',
          ),
        ),
      ),

      const SizedBox(height: 10),

      // SECONDARY BUTTON
      TextButton(
        onPressed: selectedImage == null
            ? _continue
            : _pickImage,

        child: Text(
          selectedImage == null
              ? 'Skip >'
              : 'Change Photo',

          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ),

      const SizedBox(height: 40),
    ],
  ),
),

        ],
      ),
    );
  }
}
