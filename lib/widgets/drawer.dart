
import 'package:flutter/material.dart';
import 'package:smart_litter_mat/views/history/weight_alert_history.dart';

import '../views/home.dart'; 
import '../views/profiles_cat/maintanence/all_cat_profiles.dart';
import '../views/settings/settings.dart';
import '../views/login.dart';
import '../views/alerts/all_alerts.dart';
import '../views/guide.dart';
import '../views/profiles_user/maintanence/account_overview.dart';
import '../views/history/clean_alert_history.dart';
import '../views/history/report_history.dart';

/////////////////////////////////////////MY DRAWER//////////////////////////////////////////
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 275,
      child: SingleChildScrollView(
        child: Column (
          children: [

            const SizedBox(height: 100),

            ////////////////////////////////////////////ACCOUNT SUBHEADING
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
              title: const Text('Account Overview'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => 
                      const AccountOverviewPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////RESOURCES SUBHEADING
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

            const SizedBox(height: 30),

            ////////////////////////////////////////////////HISTORY SUBHEADING
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  const Text(
                    'HISTORY',
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

            // AMMONIA BUTTON
            ListTile(
              title: const Text('Cleaning Alerts'),  //rename
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AmmoniaAlertHistoryPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),

            // WEIGHT ALERT BUTTON
            ListTile(
              title: const Text('Weight Alerts'),    //rename - weight change alerts?
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const WeightAlertHistoryPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),

            // PREVIOUS REPORTS BUTTON
            ListTile(
              title: const Text('Previous Reports'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const ReportHistoryPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            ///////////////////////////////////////////////NAVIGATION SUBHEADING
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
              title: const Text('Cat Profiles'),
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
      ),
    );
  }
}

