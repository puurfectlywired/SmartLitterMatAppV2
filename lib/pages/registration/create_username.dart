
import 'package:flutter/material.dart';
//import 'package:smart_litter_mat/pages/home.dart';

//pages
import 'create_password.dart';                  //registration page 2

//models
//import '../../models/user_profile.dart';
import '../../models/user_registration.dart';   //holds user registration data

//services
//import '../../services/auth_service.dart';    //connects user registration to firebase


////////////////////////////////////////////CREATE USER PROFILE PAGE//////////////////////////////////////////
class CreateUsername extends StatefulWidget {
  const CreateUsername({super.key});

  @override
  State<CreateUsername> createState() => _CreateUsernameState();
}

///////////////////////////////////////////CREATE USER PROFILE PAGE//////////////////////////////////////////
class _CreateUsernameState extends State<CreateUsername> {

  //controllers retrieve info from username/password text fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Stack(
          children: [

            //bits kept from app bar
            //back arrow
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

            // SCROLLABLE BODY
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            // Logo above title
                            Image.asset(
                              'assets/images/PUUR_v4.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                              color: Theme.of(context).colorScheme.onSurface,

                            ),

                            SizedBox(height: 20),

                            Text(
                              'Register',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.normal,
                              ),
                            ),

                            SizedBox(height: 70),

                            SizedBox(
                              width: 300,
                              child: Text(
                                'What should we call you?',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),

                            SizedBox(height: 10),

                            //first name field
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: firstNameController,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),

                            SizedBox(height: 20),

                            //last name field
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: lastNameController,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),

                            SizedBox(height: 80),

                            SizedBox(
                              width: 300,
                              child: Text(
                                "What's your email?",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),

                            SizedBox(height: 10),

                            // emailfield
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),

                            SizedBox(height: 30),

                            // Continue button
                            SizedBox(
                              width: 300,
                              child: ElevatedButton(
                                onPressed: () {

                                  // Get the information entered by the user
                                  final userRegistration = UserRegistration(
                                    firstName: firstNameController.text.trim(),
                                    lastName: lastNameController.text.trim(),
                                    email: emailController.text.trim(),
                                  );

                                  // Navigate to registration page 2
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => CreatePassword(
                                        user: userRegistration,
                                      ),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                                child: const Text('Continue'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
