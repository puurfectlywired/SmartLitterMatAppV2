
import 'package:flutter/material.dart';
import 'dart:async';
import '../api/api_flutter.dart';

import '../widgets/app_bar.dart';
import '../widgets/drawer.dart';
import '../widgets/bottom_nav_bar.dart';

///////////////////////////////////////////TEST PAGE///////////////////////////////////////////
class TestPage extends StatefulWidget {
  const TestPage({super.key});
  @override
  State<TestPage> createState() => _TestPage();
}
////////////////////////////////////////////TEST PAGE////////////////////////////////
class _TestPage extends State<TestPage> {
  bool ledOn = false;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();

    _statusTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        _updateLedStatus();
      },
    );
  }

  Future<void> _updateLedStatus() async {
    try {
      final status = await ApiFlutter.getLedStatus();

      if (mounted) {
        setState(() {
          ledOn = status;
        });
      }
     } catch (e) {
      //print('Could not get LED status: $e');
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: 'Test Page',
        showLogo: true,
        ),
      endDrawer: const MyDrawer(),
      body: Center(
        child: Column (
          children: [
            SizedBox(height: 200),
            ElevatedButton(
              onPressed: () async {
                final newLedState = await ApiFlutter.setLed(!ledOn);
                setState(() {
                  ledOn = newLedState;
                });
              },
              child: 
                const Text('LED Toggle'),
            ),
            SizedBox(height: 50),
            Icon(
              Icons.pets,
              size: 50,
              color: ledOn
                  ? Colors.red
                  : Colors.grey,
            ),
          ]
        ),
      ),
      bottomNavigationBar: const MyBottomNavBar(),
    );
  }
}
