
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//pages
import 'views/welcome.dart';

//themes
import 'theme/app_colours.dart';
import 'theme/theme_controller.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await ThemeController.loadTheme();

  runApp(const MyApp());
}


//////////////////////////////////////////APP//////////////////////////////////////////
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,

      builder: (context, selectedTheme, child) {

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Puurfectly WIRED',

          // system by default
          themeMode: selectedTheme,

          // APP THEMES
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,

          home: const WelcomePage(),
        );
      },
    );
  }
}