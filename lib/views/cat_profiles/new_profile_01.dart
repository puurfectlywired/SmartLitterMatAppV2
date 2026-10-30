
import 'package:flutter/material.dart';

import '../../widgets/registration_header.dart';
import '../../widgets/selection_button.dart';
import '../../theme/app_colours.dart';
import '../../models/cat_registration_model.dart';
import 'new_profile_02.dart';
import '../../services/cat_registration_nav_service.dart';

////////////////////////////////////////////NEW PROFILE PAGE 01//////////////////////////////////////////
class NewProfilePage01 extends StatefulWidget {
  const NewProfilePage01({
    super.key,
    this.registration,
  });

  final CatRegistration? registration;

  @override
  State<NewProfilePage01> createState() => _NewProfilePage01State();
}

////////////////////////////////////////////NEW PROFILE PAGE STATE//////////////////////////////////////////
class _NewProfilePage01State extends State<NewProfilePage01> {

  late final CatRegistration registration;
  // TEXT CONTROLLERS
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  String? selectedGender;
  DateTime? selectedBirthday;

  @override
  void initState() {
    super.initState();

    registration = widget.registration ?? CatRegistration();

    nameController.text = registration.name;

    selectedGender =
        registration.sex.isEmpty ? null : registration.sex;

    selectedBirthday = registration.birthday;

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


  // CANCEL CAT REGISTRATION
  void _cancelRegistration() {
    Navigator.of(context).pop();
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

    // SAVE INFORMATION TO REGISTRATION MODEL
    registration.name = nameController.text.trim();
    registration.sex = selectedGender!;
    registration.birthday = selectedBirthday;

    // NAVIGATE TO PAGE 2
   
    // NAVIGATE TO PAGE 2
    Navigator.push(
      context,
      catRegistrationRoute(
        page: NewProfilePage02(
          registration: registration,
        ),
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
                  showBackButton: false,
                ),
              ),
            ),
          ),

          // INTRODUCTION
          Text(
            'Meow!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12),

          Text(
            "Let's kick things off with the basics",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 45),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // NAME
                SizedBox(
                    width: 300,
                    child: Text(
                      'What\'s your cat\'s name?',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),

                SizedBox(height: 10),

                TextField(
                  controller: nameController,
                  maxLength: 30,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Cat Name',
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 20),

                // GENDER
                Text(
                  'Gender',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),

                SizedBox(height: 20),

                Row(
                  children: [

                    // MALE BUTTON
                    Expanded(
                      child: SelectionButton(
                        label: 'Male',
                        selected: selectedGender == 'Male',

                        onPressed: () {
                          setState(() {
                            selectedGender = 'Male';
                          });
                        },
                      ),
                    ),

                    SizedBox(width: 20),

                    // FEMALE BUTTON
                    Expanded(
                      child: SelectionButton(
                        label: 'Female',
                        selected: selectedGender == 'Female',

                        onPressed: () {
                          setState(() {
                            selectedGender = 'Female';
                          });
                        },
                      ),
                    ),

                  ],
                ),

                SizedBox(height: 50),

                // BIRTHDAY
                SizedBox(
                    width: 300,
                    child: Text(
                      'When is your cat\'s birthday?',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),

                SizedBox(height: 10),

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

                SizedBox(height: 60),

                // NEXT BUTTON
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    child: const Text('Next'),
                  ),
                ),

                SizedBox(height: 15),
                
                // CANCEL BUTTON
                SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    onPressed: _cancelRegistration,
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