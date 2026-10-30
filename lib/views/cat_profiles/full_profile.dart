
import 'package:flutter/material.dart';
import 'dart:io';

//firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//pages
import 'all_profiles.dart';
import 'edit_cat_profile.dart';
import '../report.dart';
import '../BLE/BLE_pairing.dart';

//models
import '../../models/cat_profile_model.dart';

//services
import '../../services/cat_profile_service.dart';

//other
import '../../other/graphs.dart';
import '../../widgets/drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

//ble tag status
enum BleTagStatus {
  unpaired,
  connected,
  disconnected,
}

///////////////////////////////////////////FULL PROFILE PAGE/////////////////////////////////////
class FullProfilePage extends StatefulWidget {

  final CatProfile cat;

  const FullProfilePage({
    super.key,
    required this.cat,
  });

  @override
  State<FullProfilePage> createState() => _FullProfilePageState();
}

class _FullProfilePageState extends State<FullProfilePage> {

  late CatProfile cat;

  @override
  void initState() {
    super.initState();
    cat = widget.cat;
  }

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      endDrawer: const MyDrawer(),
      

      //SCROLLABLE PAGE
      body: Column(
        children: [

          // CAT IMAGE + BACK BUTTON + MENU BUTTON
          Stack(
            children: [

              // CAT IMAGE
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[200],

                // child: cat.imagePath == null
                //     ? const Center(
                //         child: Icon(
                //           Icons.add_a_photo,
                //           size: 60,
                //           color: Colors.grey,
                //         ),
                //       )
                //     : Image.file(
                //         File(cat.imagePath!),
                //         width: double.infinity,
                //         height: 250,
                //         fit: BoxFit.cover,
                //       ),
                
                //temp replace of ^
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

                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('ERROR LOADING CAT IMAGE: $error');
                      debugPrint('IMAGE PATH: ${cat.imagePath}');

                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.red,
                        ),
                      );
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


          //SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  const SizedBox(height: 15),

                  //CAT NAME
                  Text(
                    cat.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  //BREED, SEX, AGE
                  Text(
                    '${cat.breed} • ${cat.sex} • ${cat.age} years',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // LAST VISIT - HARD CODED
                  Text(
                    'Last visit 09/30/2026 8:36PM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 25),
                  
                  //edit and ble buttons
                  Row(
                    children: [

                      // EDIT PROFILE BUTTON
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final updatedCat = await Navigator.push<CatProfile>(
                                context,
                                PageRouteBuilder<CatProfile>(
                                  pageBuilder: (_, __, ___) =>
                                      EditProfilePage(cat: cat),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );

                              // UPDATE FULL PROFILE PAGE
                              if (updatedCat != null && mounted) {
                                setState(() {
                                  cat = updatedCat;
                                });
                              }
                            },
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text(
                              'Edit Profile',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // BLE STATUS BUTTON - CONNECTED TO FIREBASE
                      Expanded(
                        child: SizedBox(
                          height: 50,

                          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseAuth.instance.currentUser == null
                                ? null
                                : FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('cats')
                                    .doc(cat.id)
                                    .snapshots(),

                            builder: (context, snapshot) {

                              // READ BLE STATUS FROM FIREBASE
                              final data = snapshot.data?.data();

                              final String bleStatus =
                                  data?['ble_status'] as String? ?? 'unpaired';

                              // BUTTON TEXT
                              final String buttonText;

                              // BUTTON ICON
                              final IconData buttonIcon;

                              switch (bleStatus) {

                                case 'connected':
                                  buttonText = 'Connected';
                                  buttonIcon = Icons.bluetooth_connected;
                                  break;

                                case 'paired':
                                  buttonText = 'Paired';
                                  buttonIcon = Icons.bluetooth;
                                  break;

                                default:
                                  buttonText = 'Unpaired';
                                  buttonIcon = Icons.bluetooth_disabled;
                              }

                              // OPEN BLE PAIRING PAGE
                              void openBlePairingPage() {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) =>
                                        BlePairingPage(cat: cat),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              }

                              // CONNECTED OR PAIRED BUTTON
                              if (bleStatus == 'connected' ||
                                  bleStatus == 'paired') {

                                return ElevatedButton.icon(
                                  onPressed: openBlePairingPage,

                                  icon: Icon(
                                    buttonIcon,
                                    size: 18,
                                  ),

                                  label: Text(
                                    buttonText,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              }

                              // UNPAIRED BUTTON
                              return OutlinedButton.icon(
                                onPressed: openBlePairingPage,

                                icon: Icon(
                                  buttonIcon,
                                  size: 18,
                                ),

                                label: Text(
                                  buttonText,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    ],
                  ),


                  const SizedBox(height: 40),

                  // CURRENT STATUS TITLE
                  _sectionTitle(
                    context,
                    'Current Status',
                  ),


                  const SizedBox(height: 15),

                  //CURRENT STATUS CARD
                  CurrentStatusCard(cat: cat),

                  const SizedBox(height: 40),

                  //WEIGHT TREND TITLE
                  _sectionTitle(
                    context,
                    'Weight Trend',
                  ),

                  const SizedBox(height: 15),

                  //WEIGHT TREND CARD
                  WeightTrendCard(cat: cat),

                  const SizedBox(height: 35),

                  //VIEW REPORT BUTTON
                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                const ReportPage(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      icon: const Icon(Icons.description),
                      label: const Text('Generate Report'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  //DELETE PROFILE BUTTON
                  SizedBox(
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () async {

                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Delete Profile'),
                              content: Text(
                                'Are you sure you want to delete ${cat.name}\'s profile?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, false);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, true);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldDelete != true || !context.mounted) {
                          return;
                        }

                        try {
                          //DELETE FROM FIREBASE
                          await ProfileService.deleteProfile(cat.id);

                          if (!context.mounted) return;

                          //RETURN TO ALL PROFILES
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  const ProfilesPage(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                            (route) => route.isFirst,
                          );

                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Could not delete cat profile.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Profile'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),

      //BOTTOM NAVIGATION
      bottomNavigationBar: const MyBottomNavBar(
        selectedIndex: 1,
        allowReselect: true,
      ),
    );
  }


  ///////////////////////////////////////////SECTION TITLE///////////////////////////////////////////
  Widget _sectionTitle(BuildContext context, String title) {

    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [

        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Divider(
            color: colors.outlineVariant,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
