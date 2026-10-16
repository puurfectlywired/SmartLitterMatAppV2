
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import '../../models/cat_profile.dart';
import '../../other/global_variables.dart';
import '../../widgets/registration_header.dart';

////////////////////////////////////////////NEW PROFILE PAGE//////////////////////////////////////////
class NewProfilePage extends StatefulWidget {
  const NewProfilePage({
    super.key,
    this.cat,
    this.title = 'Create New Profile',
    this.buttonText = 'Create Profile',
  });

  final CatProfile? cat;
  final String title;
  final String buttonText;

  @override
  State<NewProfilePage> createState() => _NewProfilePageState();
}

////////////////////////////////////////////NEW PROFILE PAGE STATE//////////////////////////////////////////
class _NewProfilePageState extends State<NewProfilePage> {

  // TEXT CONTROLLERS
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController sexController = TextEditingController();

  File? selectedImage;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    // PREFILL FIELDS WHEN EDITING
    if (widget.cat != null) {
      nameController.text = widget.cat!.name;
      ageController.text = widget.cat!.age.toString();
      breedController.text = widget.cat!.breed;
      sexController.text = widget.cat!.sex;

      if (weightUnit == 'lb') {
        weightController.text =
            (widget.cat!.weight * 2.20462).toStringAsFixed(1);
      } else if (weightUnit == 'g') {
        weightController.text =
            (widget.cat!.weight * 1000).toStringAsFixed(0);
      } else {
        weightController.text =
            widget.cat!.weight.toStringAsFixed(1);
      }

      if (widget.cat!.imagePath != null) {
        selectedImage = File(widget.cat!.imagePath!);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    breedController.dispose();
    weightController.dispose();
    sexController.dispose();

    super.dispose();
  }

  ////////////////////////////////////////////PROFILE IMAGE//////////////////////////////////////////
  Future<void> pickImage() async {
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
          ratioX: 3,
          ratioY: 2,
        ),

        uiSettings: [
          IOSUiSettings(
            title: 'Adjust Photo',
          ),

          AndroidUiSettings(
            toolbarTitle: 'Adjust Photo',
            lockAspectRatio: false,
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

  ////////////////////////////////////////////SAVE PROFILE//////////////////////////////////////////
  void saveProfile() {
    if (isSaving) return;

    final enteredWeight = double.tryParse(
      weightController.text.trim(),
    );

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a cat name.'),
        ),
      );
      return;
    }

    if (enteredWeight == null ||
        !enteredWeight.isFinite ||
        enteredWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weight.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final newCat = CatProfile(
        id: widget.cat?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        age: int.tryParse(ageController.text.trim()) ?? 0,
        breed: breedController.text.trim(),
        sex: sexController.text.trim(),
        weight: storeWeight(enteredWeight),
        imagePath: selectedImage?.path,
      );

      debugPrint('RETURNING CAT: ${newCat.name}');

      Navigator.pop(context, newCat);

    } catch (e) {
      debugPrint('PROFILE ERROR: $e');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create profile.'),
        ),
      );
    }
  }

  ////////////////////////////////////////////BUILD PAGE//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      body: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,

        children: [

          // CUSTOM REGISTRATION HEADER
          // Extend the pink header behind the status bar.
          ColoredBox(
            color: colorScheme.primary,
            child: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: const RegistrationHeader(
                progress: 0.25,
              ),
            ),
          ),

          // CAT IMAGE
          GestureDetector(
            onTap: pickImage,

            child: Container(
              width: double.infinity,
              height: 250,
              color: colorScheme.surfaceContainer,

              child: selectedImage == null

                  ? Center(
                      child: Icon(
                        Icons.add_a_photo,
                        size: 60,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    )

                  : Image.file(
                      selectedImage!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          // PROFILE INFORMATION
          Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                // NAME
                TextField(
                  controller: nameController,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // BREED
                TextField(
                  controller: breedController,
                  decoration: const InputDecoration(
                    labelText: 'Breed',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // AGE
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // SEX
                TextField(
                  controller: sexController,
                  decoration: const InputDecoration(
                    labelText: 'Sex',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // WEIGHT
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Current Weight ($weightUnit)',
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                // CREATE PROFILE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: isSaving ? null : saveProfile,
                    child: Text(widget.buttonText),
                  ),
                ),

                const SizedBox(height: 10),

                // CANCEL BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
