
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import '../../models/cat_profile.dart';
//import '../services/cat_service.dart';

import '../../other/global_variables.dart';

import '../../widgets/app_bar.dart';



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

/////////////////////////////////////////////NEW PROFILE PAGE STATE//////////////////////////////////////////
class _NewProfilePageState extends State<NewProfilePage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController sexController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    breedController.dispose();
    weightController.dispose();
    sexController.dispose();
    
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();

    if (widget.cat != null) {
      nameController.text = widget.cat!.name;
      ageController.text = widget.cat!.age;
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

  //PROFILE IMAGE
  File? selectedImage;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Open photo library
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    // User cancelled photo selection
    if (image == null) return;

    // Open cropping screen
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

    //user cancelled cropping
    if (croppedImage == null) return;

    //save cropped image
    setState(() {
      selectedImage = File(croppedImage.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: MyAppBar(
        title: widget.title,
        showBackButton: false,
        showHamburgerMenu: false,
        ),
            
      body: SingleChildScrollView(
        child: Column(
        children: [

          //CAT IMAGE
          GestureDetector(
            onTap: pickImage,
            child: Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[200],

              child: selectedImage == null

                  // No image selected yet
                  ? const Center(
                      child: Icon(
                        Icons.add_a_photo,
                        size: 60,
                        color: Colors.grey,
                      ),
                    )

                  // Display selected image
                  : Image.file(
                      selectedImage!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          //PROFILE INFO
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                //name input
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                //breed input
                TextField(
                  controller: breedController,
                  decoration: const InputDecoration(
                    labelText: 'Breed',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                //age input
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                //sex input
                TextField(
                  controller: sexController,
                  decoration: InputDecoration(
                    labelText: 'Sex',
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                //weight input
                TextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    labelText: 'Current Weight ($weightUnit)',
                    border: const OutlineInputBorder(),
                  ),
                ),

                //const Spacer(),
                const SizedBox(height: 20),

                //CREATE PROFILE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final enteredWeight = double.tryParse(weightController.text);
                      if (enteredWeight == null) {
                        return;
                      }
                      final newCat = CatProfile(
                        id: widget.cat?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        age: ageController.text,
                        breed: breedController.text,
                        sex: sexController.text,
                        weight: storeWeight(enteredWeight),
                        imagePath: selectedImage?.path,
                      );
                      Navigator.pop(context, newCat);
                    },
                    child: Text(widget.buttonText),
                  ),
                ),

                const SizedBox(height: 10),

                //CANCEL BUTTON
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      )
    );
  }
}
