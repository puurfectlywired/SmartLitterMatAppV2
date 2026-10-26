
import 'package:flutter/material.dart';
import 'dart:io';

//pages
import 'all_profiles.dart';

//models
import '../../models/cat_profile_model.dart';
import '../../models/cat_registration_model.dart';

//services
import '../../services/cat_profile_service.dart';
import '../../services/cat_registration_nav_service.dart';

//other
import '../../widgets/registration_header.dart';
import '../../theme/app_colours.dart';
import '../../other/global_variables.dart';


////////////////////////////////////////////NEW PROFILE PAGE 04//////////////////////////////////////////
class NewProfilePage04 extends StatefulWidget {
  const NewProfilePage04({
    super.key,
    required this.registration,
  });

  final CatRegistration registration;

  @override
  State<NewProfilePage04> createState() => _NewProfilePage04State();
}

////////////////////////////////////////////NEW PROFILE PAGE STATE//////////////////////////////////////////
class _NewProfilePage04State extends State<NewProfilePage04> {

  bool isSaving = false;

  ////////////////////////////////////////////FORMAT DATE//////////////////////////////////////////
  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$month/$day/${date.year}';
  }

  ////////////////////////////////////////////CALCULATE AGE//////////////////////////////////////////
  int _calculateAge(DateTime birthday) {
    final today = DateTime.now();

    int age = today.year - birthday.year;

    if (today.month < birthday.month ||
        (today.month == birthday.month &&
            today.day < birthday.day)) {
      age--;
    }

    return age;
  }

  ////////////////////////////////////////////SAVE PROFILE//////////////////////////////////////////
  Future<void> _createProfile() async {
    if (isSaving) return;

    // GET REGISTRATION INFORMATION
    final registration = widget.registration;

    // VALIDATE REQUIRED INFORMATION
    if (registration.name.trim().isEmpty ||
        registration.sex.isEmpty ||
        registration.birthday == null ||
        registration.weight == null ||
        !registration.weight!.isFinite ||
        registration.weight! <= 0) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some profile information is missing.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {

      // CREATE CAT PROFILE
      final newCat = CatProfile(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: registration.name.trim(),
        age: _calculateAge(registration.birthday!),
        breed: registration.breed,
        sex: registration.sex,
        weight: registration.weight!,
        imagePath: registration.imagePath,
      );

      // SAVE PROFILE
      await ProfileService.addProfile(newCat);

      if (!mounted) return;

      // NAVIGATE TO ALL PROFILES PAGE
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ProfilesPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
        (route) => route.isFirst,
      );

    } catch (e) {
      debugPrint('ERROR CREATING PROFILE: $e');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create cat profile.'),
        ),
      );
    }
  }

  ////////////////////////////////////////////INFORMATION ROW//////////////////////////////////////////
  Widget _informationRow(String label, String value) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: colors.onSurfaceVariant,
            ),
          ),

          const Spacer(),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CANCEL CAT REGISTRATION
  void _cancelRegistration() {
    if (isSaving) return;

    cancelCatRegistration(context);
  }

  ////////////////////////////////////////////BUILD PAGE//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final appColors = Theme.of(context).extension<AppColors>()!;

    // GET INFORMATION FROM REGISTRATION MODEL
    final registration = widget.registration;

    return Scaffold(
      backgroundColor: colors.surface,

      body: ListView(
        padding: EdgeInsets.zero,
        children: [

          // REGISTRATION HEADER
          ColoredBox(
            color: appColors.registrationHeader,
            child: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: ColoredBox(
                color: colors.surface,
                child: const RegistrationHeader(
                  progress: 1.0,
                ),
              ),
            ),
          ),

          // INTRODUCTION
          Text(
            'Looking Good!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "Let's make sure everything is correct",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 35),

          // PROFILE PHOTO
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceContainerHighest,
              ),
              child: ClipOval(
                child: registration.imagePath != null
                    ? Image.file(
                        File(registration.imagePath!),
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.pets,
                        size: 75,
                        color: colors.primary,
                      ),
              ),
            ),
          ),

          SizedBox(height: 35),

          // PROFILE INFORMATION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),

            child: Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [

                  // NAME
                  _informationRow(
                    'Name',
                    registration.name,
                  ),

                  const Divider(),

                  // GENDER
                  _informationRow(
                    'Gender',
                    registration.sex,
                  ),

                  const Divider(),

                  // BREED
                  _informationRow(
                    'Breed',
                    registration.breed.isNotEmpty
                        ? registration.breed
                        : 'Not provided',
                  ),

                  const Divider(),

                  // BIRTHDAY
                  _informationRow(
                    'Birthday',
                    registration.birthday != null
                        ? _formatDate(registration.birthday!)
                        : 'Not provided',
                  ),

                  const Divider(),

                  // WEIGHT
                  _informationRow(
                    'Weight',
                    registration.weight != null
                        ? displayWeight(registration.weight!)
                        : 'Not provided',
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 45),

          // BUTTONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // CREATE PROFILE BUTTON
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _createProfile,
                    child: isSaving
                        ? const CircularProgressIndicator()
                        : const Text('Create Profile'),
                  ),
                ),

                SizedBox(height: 15),

                // CANCEL BUTTON
                SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    onPressed: isSaving ? null : _cancelRegistration,
                    child: const Text('Cancel'),
                  ),
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
