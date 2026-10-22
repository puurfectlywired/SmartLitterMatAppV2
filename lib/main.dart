
import 'package:flutter/material.dart';


import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


import 'pages/welcome.dart';
import 'theme/app_colours.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}


//////////////////////////////////////////APP//////////////////////////////////////////
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Puurfectly WIRED',

      // FOLLOW DEVICE APPEARANCE
      themeMode: ThemeMode.system,

      // APP THEMES
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

      // HOME
      home: const WelcomePage(),
    );
  }
}