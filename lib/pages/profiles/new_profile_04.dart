
import 'package:flutter/material.dart';
import 'dart:io';

import '../../models/cat_profile.dart';
import '../../services/cat_profile_service.dart';
import '../../widgets/registration_header.dart';
import '../../theme/app_colours.dart';
import '../../other/global_variables.dart';

import 'all_profiles.dart';

////////////////////////////////////////////NEW PROFILE PAGE 04//////////////////////////////////////////
class NewProfilePage04 extends StatefulWidget {
  const NewProfilePage04({
    super.key,
    required this.initialName,
    required this.initialGender,
    required this.initialBirthday,
    required this.initialWeight,
    this.initialImagePath,
  });

  final String initialName;
  final String initialGender;
  final DateTime initialBirthday;
  final double initialWeight;
  final String? initialImagePath;

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

    setState(() {
      isSaving = true;
    });

    try {
      final newCat = CatProfile(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: widget.initialName,
        age: _calculateAge(widget.initialBirthday),
        breed: '',
        sex: widget.initialGender,
        weight: widget.initialWeight,
        imagePath: widget.initialImagePath,
      );

      // SAVE PROFILE
      await ProfileService.addProfile(newCat);

      if (!mounted) return;

      // NAVIGATE TO ALL PROFILES INSTANTLY
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

          Flexible(
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

  ////////////////////////////////////////////BUILD PAGE//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final appColors = Theme.of(context).extension<AppColors>()!;

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
          const Text(
            'Looking Good!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Let's make sure everything is correct",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 35),

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
                child: widget.initialImagePath != null
                    ? Image.file(
                        File(widget.initialImagePath!),
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

          const SizedBox(height: 35),

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
                  _informationRow(
                    'Name',
                    widget.initialName,
                  ),

                  const Divider(),

                  _informationRow(
                    'Gender',
                    widget.initialGender,
                  ),

                  const Divider(),

                  _informationRow(
                    'Birthday',
                    _formatDate(widget.initialBirthday),
                  ),

                  const Divider(),

                  _informationRow(
                    'Weight',
                    displayWeight(widget.initialWeight),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 45),

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

                const SizedBox(height: 15),

                // BACK BUTTON
                SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Go Back'),
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
