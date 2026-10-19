
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import '../../widgets/registration_header.dart';
import '../../theme/app_colours.dart';

import 'new_profile_04.dart';

////////////////////////////////////////////NEW PROFILE PAGE 03//////////////////////////////////////////
class NewProfilePage03 extends StatefulWidget {
  const NewProfilePage03({
    super.key,
    this.initialName = '',
    this.initialGender,
    this.initialBirthday,
    this.initialWeight,
  });

  final String initialName;
  final String? initialGender;
  final DateTime? initialBirthday;
  final double? initialWeight;

  @override
  State<NewProfilePage03> createState() => _NewProfilePage03State();
}

////////////////////////////////////////////NEW PROFILE PAGE STATE//////////////////////////////////////////
class _NewProfilePage03State extends State<NewProfilePage03> {

  File? selectedImage;

  ////////////////////////////////////////////PICK IMAGE//////////////////////////////////////////
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      final CroppedFile? croppedImage =
          await ImageCropper().cropImage(
        sourcePath: image.path,

        aspectRatio: const CropAspectRatio(
          ratioX: 1,
          ratioY: 1,
        ),

        uiSettings: [
          IOSUiSettings(
            title: 'Adjust Photo',
            aspectRatioLockEnabled: true,
          ),

          AndroidUiSettings(
            toolbarTitle: 'Adjust Photo',
            lockAspectRatio: true,
          ),
        ],
      );

      if (croppedImage == null || !mounted) return;

      setState(() {
        selectedImage = File(croppedImage.path);
      });

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

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NewProfilePage04(
              initialName: widget.initialName,
              initialGender: widget.initialGender!,
              initialBirthday: widget.initialBirthday!,
              initialWeight: widget.initialWeight!,
              initialImagePath: selectedImage?.path,
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

                // UPLOAD PHOTO BUTTON
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    child: Text(
                      selectedImage == null
                          ? 'Upload Photo'
                          : 'Change Photo',
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // SKIP / CONTINUE BUTTON
                TextButton(
                  onPressed: _continue,
                  child: Text(
                    selectedImage == null
                        ? 'Skip >'
                        : 'Continue >',
                    style: TextStyle(
                      fontSize: 17,
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
