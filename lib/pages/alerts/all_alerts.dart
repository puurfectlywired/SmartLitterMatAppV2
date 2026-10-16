
import 'package:flutter/material.dart';

import '../../models/cat_profile.dart';
import '../../services/profile_service.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

////////////////////////////////////////////ALERTS PAGE//////////////////////////////////////////
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

/////////////////////////////////////////////ALERTS PAGE STATE//////////////////////////////////////////
class _AlertsPageState extends State<AlertsPage> {
  
  String selectedAlertView = 'Overview';
  String? selectedCatId;
  
  List<CatProfile> catProfiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await ProfileService.getProfiles();

    if (!mounted) return;

    setState(() {
      catProfiles = profiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

  // APP BAR
  appBar: const MyAppBar(
    title: 'Alerts',
  ),

  endDrawer: const MyDrawer(),

  // SCROLLABLE PAGE
  body: SingleChildScrollView(
    child: Column(
      children: [

        const SizedBox(height: 20),

        // PROFILE SELECTION
        SizedBox(
          height: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              _profileAlertButton(
                name: 'General',
                icon: Icons.sensors,
                catId: null,
              ),

              ...catProfiles.map((cat) => _profileAlertButton(
                name: cat.name,
                icon: Icons.pets,
                catId: cat.id,
              )
              ),
            ],
          ),
        ),



        // // ALERT SELECTION
        // SizedBox(
        //   height: 90,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: [
        //       _alertTab('General'),
        //       _alertTab('Ammonia'),
        //       _alertTab('Weight'),
        //     ]
        //   ),
        // ),
        

        const SizedBox(height: 20),

        // RECENT ALERTS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'Recent Alerts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),
        ),

        //const SizedBox(height: 20),

        // WEEKLY LITTER BOX VISIT CHART
        // Only displayed for individual cats
        // if (selectedAlertView == 'General' &&
        //     selectedCatId != null)
//          const WeeklyVisitsChart(),

        // SPACE AT BOTTOM OF SCROLL VIEW
        //const SizedBox(height: 30),
      ],
    ),
  ),

  bottomNavigationBar: const MyBottomNavBar(
    selectedIndex: 3,
  ),
    );
  }

// ALERT TAB - select between alert types
// Widget _alertTab(String title) {
//   final bool selected = selectedAlertView == title;

//   return Expanded(
//     child: GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedAlertView = title;
//         });
//       },

//       child: Container(
//         height: double.infinity,
//         alignment: Alignment.center,

//         decoration: BoxDecoration(
//           color: selected
//               ? const Color(0xFFFFA6C9)
//               : Colors.transparent,

//           borderRadius: BorderRadius.circular(30),
//         ),

//         child: Text(
//           title,
//           style: TextStyle(
//             fontSize: 14,
//             color: selected
//                 ? Colors.black
//                 : Colors.grey,
//           ),
//         ),
//       ),
//     ),
//   );
// }

// PROFILE TAB - select between cat profiles
Widget _profileAlertButton({
  required String name,
  required IconData icon,
  String? catId,
}) {
  final bool selected = selectedCatId == catId;

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedCatId = catId;
      });
    },

    child: SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? const Color(0xFFF2D5DD)
                  : Colors.grey[200],
              border: selected
                  ? Border.all(
                      color: const Color(0xFFB95F79),
                      width: 3,
                    )
                  : null,
            ),
            child: Icon(
              icon,
              size: 27,
              color: selected
                  ? const Color(0xFFB95F79)
                  : Colors.grey,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}
}
