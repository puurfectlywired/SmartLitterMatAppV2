
import 'package:flutter/material.dart';

import '../pages/home.dart';
import '../pages/profiles/all_profiles.dart';
import '../pages/alerts/all_alerts.dart';
import '../pages/devices.dart';

/////////////////////////////////////MY BOTTOM NAV BAR//////////////////////////////////////////////
class MyBottomNavBar extends StatelessWidget {
  const MyBottomNavBar({
    super.key,
    this.selectedIndex,
  });

  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // NAVIGATION COLOURS
    final selectedColor = colorScheme.primary;
    final unselectedColor = colorScheme.onSurfaceVariant;

    // NAVIGATION FUNCTION
    void navigateTo(int index) {
      if (index == selectedIndex) return;

      Widget page;

      switch (index) {
        case 0:
          page = const HomePage(title: 'Puurfectly WIRED');
          break;
        case 1:
          page = const DevicesPage();
          break;
        case 2:
          page = const ProfilesPage();
          break;
        case 3:
          page = const AlertsPage();
          break;
        default:
          return;
      }

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }

    // REUSABLE NAVIGATION ITEM
    Widget navItem(int index, IconData icon, String label) {
      final isSelected = selectedIndex == index;
      final itemColor = isSelected ? selectedColor : unselectedColor;

      return Expanded(
        child: InkWell(
          onTap: () => navigateTo(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: itemColor,
              ),

              const SizedBox(height: 5),

              Text(
                label,
                style: TextStyle(
                  color: itemColor,
                  fontSize: 12,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(50),
      ),
      child: BottomAppBar(
        color: colorScheme.surfaceContainer,
        height: 90,
        padding: EdgeInsets.zero,

        child: Row(
          children: [
            navItem(0, Icons.home, 'Home'),
            navItem(1, Icons.devices, 'Devices'),
            navItem(2, Icons.pets, 'Cats'),
            navItem(3, Icons.notifications, 'Alerts'),
          ],
        ),
      ),
    );
  }
}