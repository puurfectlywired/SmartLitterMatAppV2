
import 'package:flutter/material.dart';

import '../pages/home.dart'; 
import '../pages/cat_profiles/all_profiles.dart';
import '../pages/settings.dart';
import '../pages/login.dart';
import '../pages/alerts/all_alerts.dart';
import '../pages/settings/login_info.dart';
import '../pages/guide.dart';

/////////////////////////////////////////MY DRAWER//////////////////////////////////////////
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 275,
      child: Column(
        children: [

          const SizedBox(height: 100),

          //ACCOUNT SUBHEADING
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                const Text(
                  'ACCOUNT',
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

          // login info button
          ListTile(
            //leading: const Icon(Icons.home),
            title: const Text('Login Information'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => 
                    const LoginInfoPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          //ACCOUNT SUBHEADING
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

          ListTile(
            //leading: const Icon(Icons.pets),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => 
                    const HomePage(title: ''),
                ),
              );
            },
          ),

          // login info button
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

          ListTile(
            //leading: const Icon(Icons.pets),
            title: const Text('Alerts'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => 
                    const AlertsPage(),
                ),
              );
            },
          ),

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

          //RESOURCES SUBHEADING
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                const Text(
                  'RESOURCES',
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

          // USER GUIDE BUTTON
          ListTile(
            title: const Text('User Guide'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const GuidePage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
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

