
import 'package:flutter/material.dart';

//////////////////////////////////////////CUSTOM APP COLOURS//////////////////////////////////////////
class AppColors extends ThemeExtension<AppColors> {

  final Color registrationHeader;
  final Color registrationProgress;
  final Color selectedGender;
  
  final Color catCardTitle;
  final Color catCardSubtitle;
  final Color catCardIcon;

  const AppColors({
    required this.registrationHeader,
    required this.registrationProgress,
    required this.selectedGender,
    
    required this.catCardTitle,
    required this.catCardSubtitle,
    required this.catCardIcon,
  });

  @override
  AppColors copyWith({
    Color? registrationHeader,
    Color? registrationProgress,
    Color? selectedGender,
    Color? catCardTitle,
    Color? catCardSubtitle,
    Color? catCardIcon,
  }) {
    return AppColors(
      registrationHeader:
          registrationHeader ?? this.registrationHeader,
      registrationProgress:
          registrationProgress ?? this.registrationProgress,
      selectedGender:
          selectedGender ?? this.selectedGender,

      catCardTitle: catCardTitle ?? this.catCardTitle,
      catCardSubtitle: catCardSubtitle ?? this.catCardSubtitle,
      catCardIcon: catCardIcon ?? this.catCardIcon,
    );
  }

  @override
  AppColors lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) return this;

    return AppColors(
      registrationHeader: Color.lerp(
        registrationHeader,
        other.registrationHeader,
        t,
      )!,
      registrationProgress: Color.lerp(
        registrationProgress,
        other.registrationProgress,
        t,
      )!,
      selectedGender: Color.lerp(
        selectedGender,
        other.selectedGender,
        t,
      )!,
      catCardTitle: Color.lerp(
        catCardTitle,
        other.catCardTitle,
        t,
      )!,
      catCardSubtitle: Color.lerp(
        catCardSubtitle,
        other.catCardSubtitle,
        t,
      )!,
      catCardIcon: Color.lerp(
        catCardIcon,
        other.catCardIcon,
        t,
      )!,
    );
  }
}

//////////////////////////////////////////APP THEMES//////////////////////////////////////////
class AppTheme {

  //////////////////////////////////////////LIGHT MODE//////////////////////////////////////////
  static final ThemeData light = ThemeData(
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

    // CUSTOM REGISTRATION COLOURS
    // CUSTOM APP COLOURS - LIGHT MODE
    extensions: const [
      AppColors(
        registrationHeader: Color(0xFFF2B3CB),
        registrationProgress: Color(0xFFF2B3CB),
        selectedGender: Color(0xFFF2B3CB),

        // CAT PROFILE CARDS
        catCardTitle: Color(0xFF242124),
        catCardSubtitle: Color(0xFF666168),
        catCardIcon: Color(0xFFB66D89),
      ),
    ],

    // GLOBAL BUTTON THEME
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(

        // ENABLED BUTTON
        backgroundColor: const Color(0xFFF2B3CB),
        foregroundColor: const Color(0xFF29252A),

        // DISABLED BUTTON
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade600,

        // BUTTON APPEARANCE
        minimumSize: const Size(0, 45),
        elevation: 1,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),

        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // CAT PROFILE CARDS
    cardTheme: CardThemeData(
      color: const Color(0xFFFFD7E5),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
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
  );


  //////////////////////////////////////////DARK MODE//////////////////////////////////////////
  static final ThemeData dark = ThemeData(
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

    // CUSTOM REGISTRATION COLOURS
    // CUSTOM APP COLOURS - DARK MODE
    extensions: const [
      AppColors(
        registrationHeader: Color(0xFFE5A3BD),
        registrationProgress: Color(0xFFE5A3BD),
        selectedGender: Color(0xFFE5A3BD),

        // CAT PROFILE CARDS
        catCardTitle: Color(0xFFF3EDF0),
        catCardSubtitle: Color(0xFFAAAAB2),
        catCardIcon: Color(0xFFE5A3BD),
      ),
    ],

    // GLOBAL BUTTON THEME
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(

        // ENABLED BUTTON
        backgroundColor: const Color(0xFFEFA0BD),
        foregroundColor: const Color(0xFF29252A),

        // DISABLED BUTTON
        disabledBackgroundColor: Colors.grey.shade800,
        disabledForegroundColor: Colors.grey,

        // BUTTON APPEARANCE
        minimumSize: const Size(0, 45),
        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),

        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // CAT PROFILE CARDS
    cardTheme: CardThemeData(
      color: const Color(0xFF303238),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
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
  );
}