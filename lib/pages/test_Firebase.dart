import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:flutter/material.dart';
import 'dart:async';
//import '../api/api_flutter.dart';

import '../widgets/app_bar.dart';
import '../widgets/drawer.dart';
import '../widgets/bottom_nav_bar.dart';

///////////////////////////////////////////TEST PAGE///////////////////////////////////////////
class TestFirebasePage extends StatefulWidget {
  const TestFirebasePage({super.key});
  @override
  State<TestFirebasePage> createState() => _TestPage();
}
////////////////////////////////////////////TEST PAGE////////////////////////////////
class _TestPage extends State<TestFirebasePage> {
  

  Future<void> testFirebaseConnection() async {
  try {
    final document = await FirebaseFirestore.instance
        .collection('connection_tests')
        .doc('mat001')
        .get();

    if (document.exists) {
      print('Firebase connection successful!');
      print('Data: ${document.data()}');
    } else {
      print('Document not found.');
    }
    } catch (e) {
      print('Firebase connection failed: $e');
    }
    }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: 'Test Firebase Page',
        showAppLogo: true,
        ),
      endDrawer: const MyDrawer(),
      body: Center(
        child: Column (
          children: [
            
            SizedBox(height: 200),
            
            ElevatedButton(
              onPressed: testFirebaseConnection,
              child: const Text('Test Firebase Connection'),
            ),
            
            
          ]
        ),
      ),
      bottomNavigationBar: const MyBottomNavBar(),
    );
  }
}
