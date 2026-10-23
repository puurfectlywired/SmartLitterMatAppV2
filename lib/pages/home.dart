
import 'package:flutter/material.dart';

import 'cat_profiles/new_profile_01.dart';
import 'devices.dart';

import '../widgets/app_bar.dart';
import '../widgets/drawer.dart';
import '../widgets/bottom_nav_bar.dart';

///////////////////////////////////////////HOME PAGE//////////////////////////////////////////
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

////////////////////////////////////////////HOME PAGE STATE//////////////////////////////////////////
class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: const MyAppBar(
       title: 'Puurfectly WIRED',
       showAppLogo: true,
       showBackButton: false,
       showHamburgerMenu: true,
      ),
      endDrawer: const MyDrawer(),
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // WELCOME SECTION
              Container(
                width: double.infinity,
                height: 130,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('slogan/mission statement here'),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // DEVICES HEADING
              const Row(
                children: [
                  Text(
                    'Devices',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Divider(thickness: 1),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ADD DEVICE BUTTON
              SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const DevicesPage(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: const Text('Add a Device'),
                ),
              ),

              const SizedBox(height: 40),

              // CAT PROFILES HEADING
              const Row(
                children: [
                  Text(
                    'Cat Profiles',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Divider(thickness: 1),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ADD CAT PROFILE BUTTON
              SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const NewProfilePage01(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: const Text('Create a Cat Profile'),
                ),
              ),

              const SizedBox(height: 40),

            ],
          ),
        ),
      ),

      
      bottomNavigationBar: const MyBottomNavBar(
        selectedIndex: 0,
      ),
    );
  }
}