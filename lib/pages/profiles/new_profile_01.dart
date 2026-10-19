
import 'package:flutter/material.dart';

import '../../widgets/registration_header.dart';
import '../../theme/app_colours.dart';

import 'new_profile_02.dart';

////////////////////////////////////////////NEW PROFILE PAGE 01//////////////////////////////////////////
class NewProfilePage extends StatefulWidget {
  const NewProfilePage({
    super.key,
    this.initialName = '',
    this.initialGender,
    this.initialBirthday,
  });

  final String initialName;
  final String? initialGender;
  final DateTime? initialBirthday;

  @override
  State<NewProfilePage> createState() => _NewProfilePageState();
}

////////////////////////////////////////////NEW PROFILE PAGE STATE//////////////////////////////////////////
class _NewProfilePageState extends State<NewProfilePage> {

  // TEXT CONTROLLERS
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  String? selectedGender;
  DateTime? selectedBirthday;

  @override
  void initState() {
    super.initState();

    nameController.text = widget.initialName;
    selectedGender = widget.initialGender;
    selectedBirthday = widget.initialBirthday;

    if (selectedBirthday != null) {
      birthdayController.text = _formatDate(selectedBirthday!);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  ////////////////////////////////////////////FORMAT DATE//////////////////////////////////////////
  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$month/$day/${date.year}';
  }

  ////////////////////////////////////////////SELECT BIRTHDAY//////////////////////////////////////////
  Future<void> _selectBirthday() async {

    final now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedBirthday ?? now,
      firstDate: DateTime(1990),
      lastDate: now,
      helpText: 'Select Birthday',
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      selectedBirthday = pickedDate;
      birthdayController.text = _formatDate(pickedDate);
    });
  }

  ////////////////////////////////////////////NEXT PAGE//////////////////////////////////////////
  void _nextPage() {

    // VALIDATE NAME
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your cat\'s name.'),
        ),
      );
      return;
    }

    // VALIDATE GENDER
    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your cat\'s gender.'),
        ),
      );
      return;
    }

    // VALIDATE BIRTHDAY
    if (selectedBirthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your cat\'s birthday.'),
        ),
      );
      return;
    }

    // NAVIGATE TO PAGE 2
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NewProfilePage02(
              initialName: nameController.text.trim(),
              initialGender: selectedGender!,
              initialBirthday: selectedBirthday!,
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

          //REGISTRATION HEADER
          ColoredBox(
            color: appColors.registrationHeader,
            child: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: ColoredBox(
                color: colorScheme.surface,
                child: const RegistrationHeader(
                  progress: 0.25,
                ),
              ),
            ),
          ),


          //const SizedBox(height: 20),

          // INTRODUCTION
          const Text(
            'Meow!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Let's kick things off with the basics",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 45),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // NAME
                const Text(
                  'Name',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: nameController,
                  maxLength: 30,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Cat Name',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 35),

                // GENDER
                const Text(
                  'Gender',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 25),

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

                const SizedBox(height: 50),

                // BIRTHDAY
                const Text(
                  "When is your cat's birthday?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 25),

                TextField(
                  controller: birthdayController,
                  readOnly: true,
                  onTap: _selectBirthday,

                  decoration: InputDecoration(
                    hintText: 'Select Birthday',
                    border: const OutlineInputBorder(),

                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.calendar_month,
                      ),
                      color: colorScheme.primary,
                      onPressed: _selectBirthday,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

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

  ////////////////////////////////////////////GENDER BUTTON//////////////////////////////////////////
  Widget _genderButton(String gender) {

    final bool selected = selectedGender == gender;

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
        onPressed: () {
          setState(() {
            selectedGender = gender;
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

////////////////////////////////////////////CURVED HEADER//////////////////////////////////////////
// class _CurvedHeaderClipper extends CustomClipper<Path> {

//   @override
//   Path getClip(Size size) {

//     final path = Path();

//     path.lineTo(0, size.height * 0.82);

//     path.quadraticBezierTo(
//       size.width * 0.55,
//       size.height * 0.60,
//       size.width,
//       size.height * 0.98,
//     );

//     path.lineTo(size.width, 0);
//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return false;
//   }
// }
