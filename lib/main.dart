//Author: Else

import 'package:flutter/material.dart';

import 'pages/welcome.dart';

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

      //temporary
      themeMode: ThemeMode.system,

      //LIGHT MODE EXPLICIT
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB66D89),
          brightness: Brightness.light,
        ).copyWith(

          // PINK ACCENT COLOURS
          primary: const Color(0xFFB66D89),
          onPrimary: const Color(0xFFFFFFFF),

          // MAIN BACKGROUND
          surface: const Color(0xFFF8F6F6),
          onSurface: const Color(0xFF242124),

          // NEUTRAL SURFACE COLOURS
          surfaceDim: const Color(0xFFE5E1E3),
          surfaceBright: const Color(0xFFFFFFFF),

          surfaceContainerLowest: const Color(0xFFFFFFFF),
          surfaceContainerLow: const Color(0xFFF6F4F5),
          surfaceContainer: const Color(0xFFEFEAEC),
          surfaceContainerHigh: const Color(0xFFE7E3E5),
          surfaceContainerHighest: const Color(0xFFDDD9DC),

          // SECONDARY TEXT AND ICONS
          onSurfaceVariant: const Color(0xFF666168),

          // OUTLINES AND DIVIDERS
          outline: const Color(0xFF89838A),
          outlineVariant: const Color(0xFFD0CBD0),

          // OTHER COLOURS
          inverseSurface: const Color(0xFF292B30),
          onInverseSurface: const Color(0xFFF8F6F6),
          inversePrimary: const Color(0xFFEFEAEC),
        ),

        // DRAWER
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFFF6F4F5),
          surfaceTintColor: Colors.transparent,
        ),

        // APP BAR
        appBarTheme: const AppBarThemeData(
          backgroundColor: Color(0xFFF8F6F6),
          foregroundColor: Color(0xFF242124),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),

        // SCAFFOLD BACKGROUND
        scaffoldBackgroundColor: const Color(0xFFF8F6F6),
      ),


      //DARK MODE EXPLICIT
      darkTheme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD9A6B3),
          brightness: Brightness.dark,
        ).copyWith(

          // PINK ACCENT COLOURS
          primary: const Color(0xFFE5A3BD),
          onPrimary: const Color(0xFF281B23),

          // MAIN BACKGROUND
          surface: const Color(0xFF17191D),
          onSurface: const Color(0xFFF3EDF0),

          // CHARCOAL SURFACE COLOURS
          surfaceDim: const Color(0xFF17191D),
          surfaceBright: const Color(0xFF393B40),

          surfaceContainerLowest: const Color(0xFF121316),
          surfaceContainerLow: const Color(0xFF202126),
          surfaceContainer: const Color(0xFF292B30),
          surfaceContainerHigh: const Color(0xFF303238),
          surfaceContainerHighest: const Color(0xFF393B40),

          // SECONDARY TEXT AND ICONS
          onSurfaceVariant: const Color(0xFFAAAAB2),

          // OUTLINES AND DIVIDERS
          outline: const Color(0xFF65666D),
          outlineVariant: const Color(0xFF45464D),

          // OTHER COLOURS
          inverseSurface: const Color(0xFFF3EDF0),
          onInverseSurface: const Color(0xFF17191D),
          inversePrimary: const Color(0xFF292B30),
        ),

        // DRAWER
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF202126),
          surfaceTintColor: Colors.transparent,
        ),

        // APP BAR
        appBarTheme: const AppBarThemeData(
          backgroundColor: Color(0xFF17191D),
          foregroundColor: Color(0xFFF3EDF0),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),

        // SCAFFOLD BACKGROUND
        scaffoldBackgroundColor: const Color(0xFF17191D),
      ),



      home: const WelcomePage(),
    );
  }
}


