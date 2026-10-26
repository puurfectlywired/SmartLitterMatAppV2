
import 'package:flutter/material.dart';
import 'dart:io';

//pages
import 'cat_profiles/new_profile_01.dart';
import 'guide.dart';
import 'cat_profiles/full_profile.dart';

//models
import '../models/user_data_model.dart';
import '../models/cat_profile_model.dart';

//services
import '../services/user_data_service.dart';
import '../services/cat_profile_service.dart';

//widgets
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

  //load cat profiles
  late Future<List<CatProfile>> catProfilesFuture;

  @override
  void initState() {
    super.initState();
    loadCatProfiles();
  }

// LOAD CAT PROFILES FROM FIREBASE
void loadCatProfiles() {
  catProfilesFuture = ProfileService.getProfiles();
}

  // REFRESH CAT PROFILES
  void refreshCatProfiles() {
    setState(() {
      loadCatProfiles();
    });
  }

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

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    // GET USER'S FIRST NAME FROM FIREBASE
                    FutureBuilder<UserData?>(
                      future: UserDataService().getCurrentUserData(),

                      builder: (context, snapshot) {

                        String welcomeMessage = 'Welcome!';

                        if (snapshot.hasData) {
                          final firstName = snapshot.data!.firstName.trim();

                          if (firstName.isNotEmpty) {
                            welcomeMessage = 'Welcome $firstName!';
                          }
                        }

                        return Text(
                          welcomeMessage,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'slogan/mission statement here',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // DEVICES HEADING
              const Row(
                children: [
                  Text(
                    'User Guide',
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

              // USER GUIDE BUTTON
              SizedBox(
                width: double.infinity,
                height: 80,

                child: ElevatedButton(
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
                            const GuidePage(),
                      ),
                    );
                  },

                  child: Row(
                    children: [

                      // GUIDE ICON
                      Icon(
                        Icons.menu_book,
                        size: 26,
                        color: Theme.of(context).colorScheme.primary,
                      ),

                      const SizedBox(width: 15),

                      // TITLE + SUBTITLE
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            // TITLE
                            Text(
                              'Explore the User Guide',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),

                            const SizedBox(height: 5),

                            // SUBTITLE
                            Text(
                              'Setup, features & troubleshooting',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // RIGHT ARROW
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
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

              //CAT PROFILE LIST
              FutureBuilder<List<CatProfile>>(
                future: catProfilesFuture,

                builder: (context, snapshot) {

                  // LOADING
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // ERROR
                  if (snapshot.hasError) {
                    return const Text('Unable to load cat profiles');
                  }

                  final cats = snapshot.data ?? [];

                  // NO CAT PROFILES
                  if (cats.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  // DISPLAY CAT PROFILES
                  return Column(
                    children: [

                      for (final cat in cats) ...[

                        // CAT PROFILE CARD
                        SizedBox(
                          width: double.infinity,
                          height: 80,

                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                            elevation: 0,
                          ),

                            onPressed: () async {
                              await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      FullProfilePage(cat: cat),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );

                              if (!mounted) return;

                              refreshCatProfiles();
                            },

                            child: Row(
                              children: [

                                // CAT IMAGE
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                      Theme.of(context)
                                      .colorScheme.surfaceContainerHighest,

                                  backgroundImage:
                                      cat.imagePath != null &&
                                      cat.imagePath!.isNotEmpty &&
                                      File(cat.imagePath!).existsSync()
                                          ? FileImage(File(cat.imagePath!))
                                          : null,

                                  child: cat.imagePath == null ||
                                          cat.imagePath!.isEmpty ||
                                          !File(cat.imagePath!).existsSync()
                                      ? Icon(
                                          Icons.pets,
                                          size: 30,
                                          color: Theme.of(context).colorScheme.primary,
                                        )
                                      : null,
                                ),

                                const SizedBox(width: 15),

                                // CAT NAME
                                Expanded(
                                  child: Text(
                                    cat.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // RIGHT ARROW
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  );
                },
              ),

              // ADD CAT PROFILE BUTTON
              SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    // shape:RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(40),
                    // )
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const NewProfilePage01(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );

                    if (!mounted) return;

                    refreshCatProfiles();
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