

import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/cat_profile.dart';
import '../../services/cat_service.dart';

import 'edit_profile.dart';
import '../report.dart';
import 'all_profiles.dart';

import '../../other/graphs.dart';

//import '../widgets/app_bar.dart';
import '../../widgets/drawer.dart';
import '../../widgets/bottom_nav_bar.dart';


///////////////////////////////////////////FULL PROFILE PAGE/////////////////////////////////////
class FullProfilePage extends StatelessWidget {
  
  final CatProfile cat;

  const FullProfilePage({
    super.key,
    required this.cat,
  });

@override
Widget build(BuildContext context) {
  return Scaffold(

    endDrawer: const MyDrawer(),

    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // CAT IMAGE + BACK BUTTON + MENU BUTTON
        Stack(
          children: [

            // CAT IMAGE
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[200],

              child: cat.imagePath == null
                  ? const Center(
                      child: Icon(
                        Icons.add_a_photo,
                        size: 60,
                        color: Colors.grey,
                      ),
                    )
                  : Image.file(
                      File(cat.imagePath!),
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
            ),

            // BACK BUTTON
            Positioned(
              top: 50,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // HAMBURGER MENU
            Positioned(
              top: 50,
              right: 10,
              child: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  );
                },
              ),
            ),
          ],
        ),

        // PROFILE INFORMATION
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // CAT NAME
                Center(
                  child: Text(
                    cat.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // BREED • SEX • AGE
                Center(
                  child: Text(
                    '${cat.breed} • ${cat.sex} • ${cat.age} years',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[700],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                //hardcoded for demo
                Center(
                  child: Text(
                    'Last visit 09/30/2026 8:36PM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // EDIT PROFILE BUTTON
                Center(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => 
                            EditProfilePage(cat: cat),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                      ),

                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                
                CurrentStatusCard(cat: cat),

                const SizedBox(height: 20),

                // VIEW REPORT BUTTON
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => 
                        const ReportPage(),
                      ),
                    );
                  },

                  icon: const Icon(Icons.description),

                  label: const Text('View Report'),
                ),

                const SizedBox(height: 20),

                WeightTrendCard(cat: cat),

                const SizedBox(height: 20),

                // DELETE PROFILE
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {

                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Profile'),
                            content: Text(
                              'Are you sure you want to delete ${cat.name}\'s profile?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text('Cancel'),
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldDelete == true) {
                        await CatService.deleteCat(cat.id);

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ProfilesPage(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                          (route) => false,
                        );
                      }
                    },
                    child: const Text('Delete Profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: const MyBottomNavBar(),
  );
}
}
