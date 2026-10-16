import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../home.dart';

////////////////////////////////////////////START JOURNEY PAGE//////////////////////////////////////////
class StartJourney extends StatelessWidget {
  const StartJourney({super.key, required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome to \n APP NAME',
              style: TextStyle(fontSize: 40),
            ),

            SizedBox(height: 10),

            Text(
              'Nice to meet you ${user.firstName}!',
              style: TextStyle(fontSize: 15),
            ),

            SizedBox(height: 100),

            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(
                        title: 'Puurfectly WIRED',
                      ),
                    ),
                    (route) => false,
                  );
                }, //onPressed
                child: const Text('Start Your Journey'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}