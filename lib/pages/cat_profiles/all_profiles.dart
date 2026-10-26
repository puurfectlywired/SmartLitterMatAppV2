
import 'package:flutter/material.dart';
import 'dart:io';

//pages
import 'new_profile_01.dart';
import 'full_profile.dart';

//models
import '../../models/cat_profile_model.dart';

//services
import '../../services/cat_profile_service.dart';

//themes
import '../../other/global_variables.dart';
import '../../theme/app_colours.dart';

//widgets
import '../../widgets/app_bar.dart';
import '../../widgets/drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

////////////////////////////////////////////PROFILES PAGE//////////////////////////////////////////
class ProfilesPage extends StatefulWidget {
  const ProfilesPage({super.key});

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

/////////////////////////////////////////////PROFILES PAGE STATE//////////////////////////////////////////
class _ProfilesPageState extends State<ProfilesPage> {

  List<CatProfile> catProfiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCatProfiles();
  }

  //////////////////////////////////////LOAD CAT PROFILES//////////////////////////////////////////
  Future<void> _loadCatProfiles() async {
    try {
      final profiles = await ProfileService.getProfiles();

      if (!mounted) return;

      setState(() {
        catProfiles = profiles;
        isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint('Error loading cat profiles: $e');
    }
  }

  //////////////////////////////////////ADD CAT PROFILE//////////////////////////////////////////
  Future<void> _addCatProfile() async {

    final newCat = await Navigator.push<CatProfile>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NewProfilePage01(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

    if (!mounted) return;

    // Keep existing behavior when registration returns a cat.
    if (newCat != null) {
      try {
        await ProfileService.addProfile(newCat);

      } catch (e) {
        debugPrint('ERROR ADDING CAT: $e');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save cat profile.'),
          ),
        );

        return;
      }
    }

    // Refresh profiles after returning from registration.
    await _loadCatProfiles();
  }

  //////////////////////////////////////ADD CAT BUTTON//////////////////////////////////////////
  Widget _buildAddCatButton() {

    return SizedBox(
      width: double.infinity,
      height: 80,

      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainer,
          foregroundColor:
              Theme.of(context).colorScheme.primary,
          elevation: 0,
        ),

        onPressed: _addCatProfile,

        icon: Icon(
          Icons.add_circle_outline,
          size: 30,
          color: Theme.of(context).colorScheme.primary,
        ),

        label: const Text('Create a Cat Profile'),
      ),
    );
  }

  //////////////////////////////////////BUILD PAGE//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: const MyAppBar(
        title: 'Profiles',
        showBackButton: false,
      ),

      endDrawer: const MyDrawer(),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : catProfiles.isEmpty
              ? _buildEmptyPage()
              : _buildProfilesList(),

      bottomNavigationBar: const MyBottomNavBar(
        selectedIndex: 1,
      ),
    );
  }

  ////////////////////////////////////NO PROFILES YET PAGE//////////////////////////////////////////
  Widget _buildEmptyPage() {

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              Icons.pets,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 20),

            const Text(
              'No cats added yet',
              style: TextStyle(
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 20),

            // ADD CAT BUTTON
            _buildAddCatButton(),
          ],
        ),
      ),
    );
  }

  /////////////////////////////////////WITH PROFILES ADDED//////////////////////////////////////////
  Widget _buildProfilesList() {

    final appColors = Theme.of(context).extension<AppColors>();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12),

      // Extra item for the Create a Cat Profile button
      itemCount: catProfiles.length + 1,

      itemBuilder: (context, index) {

        // ADD CAT BUTTON BELOW LAST PROFILE
        if (index == catProfiles.length) {

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),

            child: _buildAddCatButton(),
          );
        }

        // SELECT CAT PROFILE
        final cat = catProfiles[index];

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),

          child: Card(
            color: Theme.of(context).colorScheme.surfaceContainer,
            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),

            clipBehavior: Clip.antiAlias,

            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),

              // CAT IMAGE
              leading: ClipOval(
                child: SizedBox(
                  width: 55,
                  height: 55,

                  child: cat.imagePath != null
                      ? Image.file(
                          File(cat.imagePath!),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Theme.of(context)
                              .colorScheme.surfaceContainerHighest,

                          child: Icon(
                            Icons.pets,
                            size: 30,
                            color: Theme.of(context)
                                .colorScheme.primary,
                          ),
                        ),
                ),
              ),

              // CAT NAME
              title: Text(
                cat.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // CAT INFORMATION
              subtitle: Text(
                'Age: ${cat.age} years   Weight: ${displayWeight(cat.weight)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme.onSurfaceVariant,
                ),
              ),

              // RIGHT ARROW
              trailing: Icon(
                Icons.chevron_right,
                color: appColors?.catCardIcon ??
                    Theme.of(context).colorScheme.primary,
              ),

              // OPEN FULL PROFILE
              onTap: () async {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,

                    pageBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                    ) => FullProfilePage(cat: cat),
                  ),
                );

                if (!mounted) return;

                // Refresh after returning from full profile
                await _loadCatProfiles();
              },
            ),
          ),
        );
      },
    );
  }
}
