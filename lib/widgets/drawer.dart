
import 'package:flutter/material.dart';

import '../pages/home.dart'; 
import '../pages/profiles/all_profiles.dart';
import '../pages/settings.dart';
import '../pages/test.dart';
import '../pages/login.dart';

/////////////////////////////////////////MY DRAWER//////////////////////////////////////////
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 275,
      child: Column(
        children: [
          //TITLE
          const SizedBox(
            height: 100,
            // child: Center(
            //   child: Text(
            //     'Menu',
            //     style: TextStyle(
            //       fontSize: 20,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
          ),

          //NAVIGATION SUBHEADING
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                const Text(
                  'NAVIGATION',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Divider(
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),

          //HOME BUTTON
          ListTile(
            //leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => 
                    const HomePage(title: 'Puurfectly WIRED'),
                ),
              );
            },
          ),

          //PROFILES BUTTON
          ListTile(
            //leading: const Icon(Icons.pets),
            title: const Text('Cats'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => 
                    const ProfilesPage(),
                ),
              );
            },
          ),

          //SETTINGS BUTTON
          ListTile(
            //leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => 
                    const SettingsPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          //NAVIGATION SUBHEADING
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                const Text(
                  'TEST',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Divider(
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),

          //TEST BUTTON
          ListTile(
            //leading: const Icon(Icons.home),
            title: const Text('Test'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => 
                    const TestPage(),
                ),
              );
            },
          ),

          // Pushes Logout to the bottom
          const Spacer(),

          //LOGOUT BUTTON
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const LoginPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

