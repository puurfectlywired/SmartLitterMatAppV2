
import 'package:flutter/material.dart';

import '../other/global_variables.dart';

import '../widgets/app_bar.dart';
import '../widgets/drawer.dart';
import '../widgets/bottom_nav_bar.dart';

////////////////////////////////////////////SETTINGS PAGE//////////////////////////////////////////
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

////////////////////////////////////////////SETTINGS PAGE STATE//////////////////////////////////////////
class _SettingsPageState extends State<SettingsPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: const MyAppBar(
        title: 'Settings'
        ),
      endDrawer: const MyDrawer(),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            'Weight Units',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          SegmentedButton<String>(
            segments: const [

              ButtonSegment<String>(
                value: 'lb',
                label: Text('Pounds'),
              ),

              ButtonSegment<String>(
                value: 'kg',
                label: Text('Kilograms'),
              ),

              ButtonSegment<String>(
                value: 'g',
                label: Text('Grams'),
              ),

            ],


            selected: {weightUnit},

            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                weightUnit = newSelection.first;
              });
            },
          ),

        ],
      ),

      bottomNavigationBar: const MyBottomNavBar(),
    );
  }
}
