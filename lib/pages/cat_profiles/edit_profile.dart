
import 'package:flutter/material.dart';
import 'dart:io';

//images
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../services/local_image_service.dart';

// MODELS
import '../../models/cat_profile_model.dart';

// SERVICES
import '../../services/cat_profile_service.dart';

// OTHER
import '../../other/global_variables.dart';

//////////////////////////////////////////EDIT PROFILE PAGE//////////////////////////////////////////
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.cat,
  });

  final CatProfile cat;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

//////////////////////////////////////////EDIT PROFILE STATE//////////////////////////////////////////
class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController nameController;
  late final TextEditingController breedController;
  late final TextEditingController ageController;
  late final TextEditingController weightController;

  late String selectedSex;
  bool isSaving = false;

  String? selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    selectedImagePath = widget.cat.imagePath;

    nameController = TextEditingController(text: widget.cat.name);
    breedController = TextEditingController(text: widget.cat.breed);
    ageController = TextEditingController(
      text: widget.cat.age.toString(),
    );
    weightController = TextEditingController(
      text: widget.cat.weight.toString(),
    );

    selectedSex = widget.cat.sex;
  }

  @override
  void dispose() {
    nameController.dispose();
    breedController.dispose();
    ageController.dispose();
    weightController.dispose();
    super.dispose();
  }

  //////////////////////////////////////////SAVE CHANGES//////////////////////////////////////////
  Future<void> _saveChanges() async {
    if (isSaving) return;

    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim());
    final weight = double.tryParse(weightController.text.trim());

    if (name.isEmpty ||
        age == null ||
        age < 0 ||
        weight == null ||
        !weight.isFinite ||
        weight <= 0 ||
        selectedSex.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid profile information.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final updatedCat = CatProfile(
        id: widget.cat.id,
        name: name,
        age: age,
        breed: breedController.text.trim(),
        sex: selectedSex,
        weight: weight,
        imagePath: selectedImagePath,
      );

      // UPDATE EXISTING CAT PROFILE IN FIREBASE
      await ProfileService.updateProfile(updatedCat);

      if (!mounted) return;

      // RETURN UPDATED CAT TO FULL PROFILE PAGE
      Navigator.pop(context, updatedCat);
    } catch (e) {
      debugPrint('ERROR UPDATING PROFILE: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update cat profile.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  //////////////////////////////////////////EDIT FIELD//////////////////////////////////////////
  Widget _editField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

//////////////////////////////////////////SELECT PROFILE PHOTO//////////////////////////////////////////
Future<void> _selectProfilePhoto() async {
  try {

    // OPEN PHOTO LIBRARY
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;

    // CROP IMAGE
    final CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,

      uiSettings: [

        // IOS CIRCULAR CROPPER
        IOSUiSettings(
          title: 'Adjust Photo',
          cropStyle: CropStyle.circle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),

        // ANDROID CIRCULAR CROPPER
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

    // UPDATE PROFILE PHOTO PREVIEW
    setState(() {
      selectedImagePath = savedImagePath;
    });

    debugPrint('UPDATED CAT IMAGE SAVED TO: $savedImagePath');

  } catch (e) {
    debugPrint('ERROR SELECTING PROFILE PHOTO: $e');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not select profile photo.'),
      ),
    );
  }
}

  //////////////////////////////////////////BUILD PAGE//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: colors.surface,
        automaticallyImplyLeading: false,
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 25,
        ),
        children: [

          //const SizedBox(height: 12),

          const Text(
            "Let's update your cat's information",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 35),

          // PROFILE PHOTO
          Center(
            child: GestureDetector(
              onTap: isSaving ? null : _selectProfilePhoto,

              child: Stack(
                clipBehavior: Clip.none,
                children: [

                  // CIRCULAR PROFILE PHOTO
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surfaceContainerHighest,
                    ),

                    child: ClipOval(
                      child: selectedImagePath != null
                          ? Image.file(
                              File(selectedImagePath!),
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.pets,
                              size: 75,
                              color: colors.primary,
                            ),
                    ),
                  ),

                  // EDIT PHOTO ICON
                  Positioned(
                    bottom: 0,
                    right: 0,

                    child: Container(
                      width: 42,
                      height: 42,

                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.surface,
                          width: 3,
                        ),
                      ),

                      child: Icon(
                        Icons.camera_alt,
                        color: colors.onPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 35),

          // PROFILE INFORMATION
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _editField('Name', nameController),

                _editField('Breed', breedController),

                _editField(
                  'Age',
                  ageController,
                  keyboardType: TextInputType.number,
                ),

                _editField(
                  'Weight',
                  weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),

                const SizedBox(height: 15),

                // GENDER
                const Text(
                  'Gender',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [

                    Expanded(
                      child: _genderButton('Male'),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: _genderButton('Female'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 45),

          // SAVE CHANGES BUTTON
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: isSaving ? null : _saveChanges,
              child: isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            ),
          ),

          const SizedBox(height: 15),

          // CANCEL BUTTON
          SizedBox(
            height: 55,
            child: OutlinedButton(
              onPressed: isSaving
                  ? null
                  : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

//////////////////////////////////////////GENDER BUTTON//////////////////////////////////////////
Widget _genderButton(String gender) {

  final bool selected = selectedSex == gender;

  final buttonStyle = ElevatedButtonTheme.of(context).style;

  final selectedColor = buttonStyle?.backgroundColor
      ?.resolve(<WidgetState>{}) ??
      Theme.of(context).colorScheme.primary;

  final selectedTextColor = buttonStyle?.foregroundColor
      ?.resolve(<WidgetState>{}) ??
      Theme.of(context).colorScheme.onPrimary;

  return SizedBox(
    height: 55,

    child: OutlinedButton(
      onPressed: isSaving
          ? null
          : () {
              setState(() {
                selectedSex = gender;
              });
            },

      style: OutlinedButton.styleFrom(
        backgroundColor: selected
            ? selectedColor
            : Theme.of(context).colorScheme.surfaceContainer,

        foregroundColor: selected
            ? selectedTextColor
            : Theme.of(context).colorScheme.onSurface,

        side: BorderSide(
          color: selected
              ? selectedColor
              : Theme.of(context).colorScheme.outline,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),

      child: Text(
        gender,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

}