
import 'package:flutter/material.dart';

import '../../other/global_variables.dart';
import '../../widgets/registration_header.dart';
import '../../theme/app_colours.dart';

import 'new_profile_03.dart';

////////////////////////////////////////////NEW PROFILE PAGE 02//////////////////////////////////////////
class NewProfilePage02 extends StatefulWidget {
  const NewProfilePage02({
    super.key,
    this.initialName = '',
    this.initialGender,
    this.initialBirthday,
  });

  final String initialName;
  final String? initialGender;
  final DateTime? initialBirthday;

  @override
  State<NewProfilePage02> createState() => _NewProfilePage02State();
}

////////////////////////////////////////////NEW PROFILE PAGE STATE//////////////////////////////////////////
class _NewProfilePage02State extends State<NewProfilePage02> {

  // TEXT CONTROLLER
  final TextEditingController weightController = TextEditingController();

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  ////////////////////////////////////////////NEXT PAGE//////////////////////////////////////////
  void _nextPage() {

    // GET ENTERED WEIGHT
    final enteredWeight = double.tryParse(
      weightController.text.trim(),
    );

    // VALIDATE WEIGHT
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

    // CONVERT WEIGHT TO KG FOR STORAGE
    final weightKg = storeWeight(enteredWeight);

    // NAVIGATE TO PAGE 3
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NewProfilePage03(
              initialName: widget.initialName,
              initialGender: widget.initialGender,
              initialBirthday: widget.initialBirthday,
              initialWeight: weightKg,
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
                  progress: 0.50,
                ),
              ),
            ),
          ),

          // INTRODUCTION
          const Text(
            'Almost there!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Let's get your cat's current weight",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 65),

          // WEIGHT INFORMATION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // WEIGHT LABEL
                const Text(
                  'How much does your cat weigh?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 25),

                // WEIGHT INPUT
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,

                  decoration: InputDecoration(
                    hintText: 'Current Weight',
                    suffixText: weightUnit,
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),

                // EXPLANATION
                Text(
                  'This gives us a starting point for tracking changes in your cat\'s weight over time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 100),

                // NEXT BUTTON
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    child: const Text('Next'),
                  ),
                ),

                const SizedBox(height: 15),

                // CANCEL BUTTON
                SizedBox(
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
