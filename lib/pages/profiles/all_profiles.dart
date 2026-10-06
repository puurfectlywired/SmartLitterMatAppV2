
import 'package:flutter/material.dart';
import 'dart:io';

import '../../models/cat_profile.dart';
import '../../services/cat_service.dart';

import '../../other/global_variables.dart';

import 'new_profile.dart';
import 'full_profile.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCatProfiles();
  }

  Future<void> _loadCatProfiles() async {
    final cats = await CatService.getCats();
    setState(() {
      catProfiles = cats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: 'Profiles'
        ),
      endDrawer: const MyDrawer(),
      
      body: catProfiles.isEmpty
        ? _buildEmptyPage()     //no cat profiles added
        : _buildProfilesList(), //cat profiles added

      bottomNavigationBar: const MyBottomNavBar(),
    );
  }

  //NO PROFILES YET PAGE
  Widget _buildEmptyPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pets,
            size: 80,
          ),

          const SizedBox(height: 20),

          const Text(
            'No cats added yet',
            style: TextStyle(
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 20),

          //ADD CAT BUTTON
          ElevatedButton(
            onPressed: () async {
              //opens new profile page and waits
              final newCat = await Navigator.push<CatProfile>(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const NewProfilePage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                if (newCat != null) {
                  await CatService.addCat(newCat);
                  await _loadCatProfiles();
                }
            },
            child: const Text('Add Cat'),
          ),
        ],
      ),
    );
  }

  //WITH PROFILES ADDED
  Widget _buildProfilesList() {
  return ListView.builder(
    // +1 is for the add another cat button
    padding: const EdgeInsets.only(top: 12),
    itemCount: catProfiles.length + 1,
    itemBuilder: (context, index) {


      if (index == catProfiles.length) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () async {

              final newCat = await Navigator.push<CatProfile>(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const NewProfilePage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );

              //empty state remains the same
              if (newCat != null) {
                await CatService.addCat(newCat);
                await _loadCatProfiles();
              }
            },
            child: const Text('Add Another Cat'),
          ),
        );
      }

      // Otherwise display the cat
      final cat = catProfiles[index];

      //info displayed on cat profile outside of full profile page
      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,

          // box border
          // border: Border.all(
          //   color: Theme.of(context).colorScheme.secondaryContainer,
          //   width: 1,
          // ),
          borderRadius: BorderRadius.circular(15),
        ),

        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          // minTileHeight: 0,
          // minVerticalPadding: 0,

          leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 55,
            height: 55,
            child: cat.imagePath != null
                ? Image.file(
                    File(cat.imagePath!),
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.pets,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
          ),
          ),
          
          //CAT NAME
          title: Text(
            cat.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          //
          subtitle: Text(
            'Age: ${cat.age} years   Weight: ${displayWeight(cat.weight)}',
          ),

          //ARROW
          trailing: const Icon(
            Icons.chevron_right,
          ),

          //CLICK INTO FULL PROFILE
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    FullProfilePage(cat: cat),
              ),
            );
          },
        ),
      );
    },
  );
}
}
