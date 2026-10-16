import 'package:flutter/material.dart';

import '../widgets/app_bar.dart';
import '../widgets/drawer.dart';
import '../widgets/bottom_nav_bar.dart';

////////////////////////////////////////////DEVICES PAGE//////////////////////////////////////////
class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

////////////////////////////////////////////DEVICES PAGE STATE//////////////////////////////////////////
class _DevicesPageState extends State<DevicesPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: const MyAppBar(
        title: 'Devices',
        showBackButton: true,
        showHamburgerMenu: true,
        ),
      endDrawer: const MyDrawer(),
      
      body: Column(
        
      ),

      bottomNavigationBar: const MyBottomNavBar(
        selectedIndex: 1,
      ),
    );
  }
}