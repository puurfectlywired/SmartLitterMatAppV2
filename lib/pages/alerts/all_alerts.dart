
import 'package:flutter/material.dart';

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
  String selectedAlertProfile = 'General';
  
  //hardcoded for demo
  final demoWeights = [
  10.8,
  10.7,
  10.7,
  10.6,
  10.5,
  10.4,
  ];

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
              ),

              _profileAlertButton(
                name: 'Olive',
                icon: Icons.pets,
              ),

              _profileAlertButton(
                name: 'Winston',
                icon: Icons.pets,
              ),

              _profileAlertButton(
                name: 'Miso',
                icon: Icons.pets,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),


        // ALERT SELECTION
        SizedBox(
          height: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _alertTab('General'),
              _alertTab('Ammonia'),
              _alertTab('Weight'),
            ]
          ),
        ),
        

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

              const SizedBox(height: 12),

              // AMMONIA ALERT
              // AlertCard(
              //   icon: Icons.air,
              //   title: 'High Ammonia Level',
              //   description:
              //       'Ammonia concentration exceeded the recommended threshold.',
              //   time: 'Today • 10:42 AM',
              //   category: 'General',
              //   iconColor: Colors.orange,
              // ),

              // // WEIGHT ALERT
              // AlertCard(
              //   icon: Icons.monitor_weight_outlined,
              //   title: 'Weight Decrease Detected',
              //   description:
              //       'Olive\'s weight decreased from 9.2 lb to 8.8 lb.',
              //   time: 'Yesterday • 8:36 PM',
              //   category: 'Olive',
              //   iconColor: Colors.pink,
              // ),

              // // LITTER BOX VISIT ALERT
              // AlertCard(
              //   icon: Icons.pets,
              //   title: 'Frequent Litter Box Visits',
              //   description:
              //       'Olive visited the litter box more frequently than usual.',
              //   time: 'Sep 28 • 6:15 PM',
              //   category: 'Olive',
              //   iconColor: Colors.purple,
              // ),

              // // AMMONIA ALERT
              // AlertCard(
              //   icon: Icons.air,
              //   title: 'Elevated Ammonia Level',
              //   description:
              //       'Ammonia concentration was above the normal operating range.',
              //   time: 'Sep 26 • 9:14 AM',
              //   category: 'General',
              //   iconColor: Colors.orange,
              // ),

              // // WEIGHT INCREASE ALERT
              // AlertCard(
              //   icon: Icons.trending_up,
              //   title: 'Weight Increase Detected',
              //   description:
              //       'Olive\'s weight increased by 0.4 lb over seven days.',
              //   time: 'Sep 22 • 7:52 PM',
              //   category: 'Olive',
              //   iconColor: Colors.blue,
             // ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // WEEKLY LITTER BOX VISIT CHART
        // Only displayed for individual cats
        if (selectedAlertView == 'Overview' &&
            selectedAlertProfile != 'General')
//          const WeeklyVisitsChart(),

        // SPACE AT BOTTOM OF SCROLL VIEW
        const SizedBox(height: 30),
      ],
    ),
  ),

  bottomNavigationBar: const MyBottomNavBar(),
    );
  }

// ALERT TAB - select between alert types
Widget _alertTab(String title) {
  final bool selected = selectedAlertView == title;

  return Expanded(
    child: GestureDetector(
      onTap: () {
        setState(() {
          selectedAlertView = title;
        });
      },

      child: Container(
        height: double.infinity,
        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFA6C9)
              : Colors.transparent,

          borderRadius: BorderRadius.circular(30),
        ),

        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: selected
                ? Colors.black
                : Colors.grey,
          ),
        ),
      ),
    ),
  );
}

// PROFILE TAB - select between cat profiles
Widget _profileAlertButton({
  required String name,
  required IconData icon,
}) {
  final bool selected = selectedAlertProfile == name;

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedAlertProfile = name;
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
