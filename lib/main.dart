//Author: Else
import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'dart:io';
// import 'dart:async';

// import 'api/api_flutter.dart';
// import 'models/cat_profile.dart';
// import 'services/cat_service.dart';

// import 'pages/alerts.dart';
// import 'pages/home.dart';
// import 'pages/login.dart';
// import 'pages/profiles.dart';
// import 'pages/new_profile.dart';
import 'pages/welcome.dart';

// import 'widgets/app_bar.dart';
// import 'widgets/bottom_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

//////////////////////////////////////////APP//////////////////////////////////////////
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Puurfectly WIRED',
      //themeMode: ThemeMode,

      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 255, 213, 231),
          brightness: Brightness.light,
          ), // colourScheme.fromSeed
      ),

      darkTheme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 255, 213, 231),
          brightness: Brightness.dark,
          ), // colourScheme.fromSeed
      ),

      home: const WelcomePage(),
    );
  }
}


