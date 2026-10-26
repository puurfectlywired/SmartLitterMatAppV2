
import 'package:flutter/material.dart';

//pages
import 'new_profile_03.dart';

//models
import '../../models/cat_registration_model.dart';

//other
import '../../other/global_variables.dart';
import '../../widgets/registration_header.dart';
import '../../theme/app_colours.dart';



////////////////////////////////////////////NEW PROFILE PAGE 02//////////////////////////////////////////
class NewProfilePage02 extends StatefulWidget {
  const NewProfilePage02({
    super.key,
    required this.registration,
  });

  final CatRegistration registration;

  @override
  State<NewProfilePage02> createState() => _NewProfilePage02State();
}

////////////////////////////////////////////NEW PROFILE PAGE STATE//////////////////////////////////////////
class _NewProfilePage02State extends State<NewProfilePage02> {

  // TEXT CONTROLLER
  final TextEditingController weightController = TextEditingController();
  final TextEditingController breedController = TextEditingController();

  @override
  void initState() {
  super.initState();

  // LOAD PREVIOUSLY ENTERED BREED
  breedController.text = widget.registration.breed;
}

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }


  // CANCEL CAT REGISTRATION
  // void _cancelRegistration() {
  //   Navigator.of(context).popUntil((route) {
  //     return route.settings.name == '/' || route.isFirst;
  //   });
  // }


  // CANCEL CAT REGISTRATION
  void _cancelRegistration() {
    int pagesToClose = 2;

    Navigator.of(context).popUntil((route) {
      if (pagesToClose == 0) return true;
      pagesToClose--;
      return false;
    });
  }



  ////////////////////////////////////////////NEXT PAGE//////////////////////////////////////////
  void _nextPage() {

    // VALIDATE WEIGHT
    final weight = double.tryParse(
      weightController.text.trim(),
    );

    if (weight == null || !weight.isFinite || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weight.'),
        ),
      );
      return;
    }

    // SAVE INFORMATION TO REGISTRATION MODEL
    widget.registration.weight = storeWeight(weight);
    widget.registration.breed = breedController.text.trim();

    // NAVIGATE TO PAGE 3
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NewProfilePage03(
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

          Text(
            "Let's learn a little more about ${widget.registration.name}",
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

              const SizedBox(height: 45),

              // BREED LABEL
              const Text(
                'What breed is your cat?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 25),

              // BREED INPUT
              TextField(
                controller: breedController,
                maxLength: 50,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Cat Breed (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 65),

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
                    onPressed: _cancelRegistration,
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
