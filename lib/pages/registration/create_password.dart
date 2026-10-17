
import 'package:flutter/material.dart';

import 'start_journey.dart';
import '../../models/user_profile.dart';



////////////////////////////////////////////CREATE PASSWORD PAGE//////////////////////////////////////////
class CreatePassword extends StatefulWidget {
  const CreatePassword({
    super.key,
    required this.user});

  final UserProfile user;

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}


///////////////////////////////////////////CREATE PASSWORD PAGE//////////////////////////////////////////
class _CreatePasswordState extends State<CreatePassword> {
  
  //controllers retrieve info from username/password text fields
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();

  Color get highlightColor =>
      Theme.of(context).colorScheme.primary;
  
  bool get passwordInvalid =>
      passwordFieldActive && !allRequirementsMet;

  //continue button conditions
  bool get passwordsMatch =>
      passwordController.text == confirmPasswordController.text;
  bool get canContinue =>
      allRequirementsMet && passwordsMatch;    

  //password field settings
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool passwordFieldActive = false;

  //password conditions
  bool get hasMinLength =>
      passwordController.text.length >= 8;

  bool get hasUppercase =>
      RegExp(r'[A-Z]').hasMatch(passwordController.text);

  bool get hasLowercase =>
      RegExp(r'[a-z]').hasMatch(passwordController.text);

  bool get hasNumber =>
      RegExp(r'[0-9]').hasMatch(passwordController.text);

  bool get hasSpecialCharacter =>
      RegExp(r'[^a-zA-Z0-9]').hasMatch(passwordController.text);

  bool get allRequirementsMet =>
      hasMinLength &&
      hasUppercase &&
      hasLowercase &&
      hasNumber &&
      hasSpecialCharacter;
      
  //controls start up?
  @override
  void initState() {
    super.initState();

    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) {
        setState(() {
          passwordFieldActive = true;
        });
      }
    });
  }

  //dispose of __ after
  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

//controls password requirements behaviour
Widget passwordRequirement(String text, bool isMet) {
  final Color highlightColor =
      Theme.of(context).colorScheme.primary;

  final Color requirementColor = isMet && passwordFieldActive
      ? highlightColor
      : Colors.grey;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),

    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        // Requirement text
        Text(
          '• $text',
          style: TextStyle(
            fontSize: 12,
            color: requirementColor,
          ),
        ),

        // Checkmark when requirement is met
        if (isMet && passwordFieldActive)
          Icon(
            Icons.check,
            size: 16,
            color: highlightColor,
          ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Stack(
          children: [
            //bits kept from app bar - back arrow
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            //body
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  // Logo above title
                  Image.asset(
                    'assets/images/cat_icon.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),

                  // Page title
                  Text(
                    'Create Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 40),

                  //create password text label
                  SizedBox(
                    width: 300,
                    child: Text(
                      'Create Password',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  //create password field with eye icon
                  SizedBox(
                    width: 300,

                    child: TextFormField(
                      controller: passwordController,
                      focusNode: passwordFocusNode,

                      obscureText: !passwordVisible,

                      onChanged: (value) {
                        setState(() {});
                      },

                      decoration: InputDecoration(
                        hintText: 'Password',

                        //error message
                        // errorText: passwordInvalid
                        //     ? 'Invalid password'
                        //     : null,

                        //normal border
                        border: const OutlineInputBorder(),

                        //red border when password is invalid
                        // enabledBorder: OutlineInputBorder(
                        //   borderSide: BorderSide(
                        //     color: passwordInvalid
                        //         ? Colors.red
                        //         : Theme.of(context).colorScheme.outline,
                        //   ),
                        // ),

                        // //red border when selected and invalid
                        // focusedBorder: OutlineInputBorder(
                        //   borderSide: BorderSide(
                        //     color: passwordInvalid
                        //         ? Colors.red
                        //         : highlightColor,
                        //     width: 2,
                        //   ),
                        // ),

                        // //error borders
                        // errorBorder: const OutlineInputBorder(
                        //   borderSide: BorderSide(
                        //     color: Colors.red,
                        //   ),
                        // ),

                        // focusedErrorBorder: const OutlineInputBorder(
                        //   borderSide: BorderSide(
                        //     color: Colors.red,
                        //     width: 2,
                        //   ),
                        // ),

                        //eye icon
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),

                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  //password requirements
                  SizedBox(
                    width: 300,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'Password must contain:',
                          style: TextStyle(fontSize: 12),
                        ),

                        const SizedBox(height: 6),

                        passwordRequirement(
                          'At least 8 characters',
                          hasMinLength,
                        ),

                        passwordRequirement(
                          'One uppercase letter',
                          hasUppercase,
                        ),

                        passwordRequirement(
                          'One lowercase letter',
                          hasLowercase,
                        ),

                        passwordRequirement(
                          'One number',
                          hasNumber,
                        ),

                        passwordRequirement(
                          'One special character',
                          hasSpecialCharacter,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  //confirm password text label
                  SizedBox(
                    width: 300,
                    child: Text(
                      'Confirm Password',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  //confirm password field
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: confirmPasswordController,
                      //focusNode: passwordFocusNode,
                      obscureText: !confirmPasswordVisible,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            confirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              confirmPasswordVisible = !confirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30),

                  //continue button
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: canContinue
                          ? () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      StartJourney(user: widget.user),
                                ),
                              );
                            }
                          : null,
                      child: const Text('Continue'),
                    ),
                  ),

                  // Continue button
                  // SizedBox(
                  //   width: 300,
                  //   child: ElevatedButton(
                  //     onPressed: () {
                            // Navigator.push(
                              // context,
                              // PageRouteBuilder(
                              //   pageBuilder: (context, animation, secondaryAnimation) => 
                              //   StartJourney(user: widget.user)
                              // ),
                  //           );
                  //         }, //onPressed
                  //     child: const Text('Continue'),
                  //   ),
                  // ),
                ]
              )
            ),
          ]
        )
      )
    );
  }
}