
import 'package:flutter/material.dart';

import 'start_journey.dart';
import '../../models/user_profile.dart';



////////////////////////////////////////////CREATE USER PASSWORD PAGE//////////////////////////////////////////
class CreatePassword extends StatefulWidget {
  const CreatePassword({
    super.key,
    required this.user});

  final UserProfile user;

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}


///////////////////////////////////////////CREATE USER PASSWORD PAGE//////////////////////////////////////////
class _CreatePasswordState extends State<CreatePassword> {
  
  //controllers retrieve info from username/password text fields
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
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

            //body
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Text(
                    'Create Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.normal,
                    )
                  ),

                  SizedBox(height: 70),

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

                  //password field
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  SizedBox(
                    width: 300,
                    child: Text(
                      'Password must contain: \n • At least 8 characters \n • One uppercase letter \n • One lowercase letter \n • One number \n • One special character',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

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
                    child: TextField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
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
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => 
                                StartJourney(user: widget.user)
                              ),
                            );
                          }, //onPressed
                      child: const Text('Continue'),
                    ),
                  ),
                ]
              )
            ),
          ]
        )
      )
    );
  }
}