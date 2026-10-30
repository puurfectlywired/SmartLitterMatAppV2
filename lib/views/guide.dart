import 'package:flutter/material.dart';

import '../widgets/app_bar.dart';
import '../widgets/drawer.dart';
import '../widgets/bottom_nav_bar.dart';

////////////////////////////////////////////Guide PAGE//////////////////////////////////////////
class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

////////////////////////////////////////////Guide PAGE STATE//////////////////////////////////////////
class _GuidePageState extends State<GuidePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: const MyAppBar(
        title: 'User Guide',
        showBackButton: false,
        showHamburgerMenu: true,
        ),
      endDrawer: const MyDrawer(),
      
      body: Column(
        
      ),

      bottomNavigationBar: const MyBottomNavBar(
        selectedIndex: 3,
      ),
    );
  }
}