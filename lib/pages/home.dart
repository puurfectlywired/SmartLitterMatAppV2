
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: const MyAppBar(
        title: 'Puurfectly WIRED',
        showLogo: true,
        ),
      
      endDrawer: const MyDrawer(),
      
      body: Center(
        
      ),
      
      bottomNavigationBar: const MyBottomNavBar(),
    );
  }
}