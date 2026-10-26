
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


//////////////////////////////////////////THEME CONTROLLER//////////////////////////////////////////
class ThemeController {

  // DEFAULT TO SYSTEM THEME
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.system);


  //////////////////////////////////////////LOAD SAVED THEME////////////////////////////////////////
  static Future<void> loadTheme() async {

    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString('appTheme');

    switch (savedTheme) {

      case 'light':
        themeMode.value = ThemeMode.light;
        break;

      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;

      default:
        themeMode.value = ThemeMode.system;
    }
  }


  //////////////////////////////////////////SAVE SELECTED THEME////////////////////////////////////////
  static Future<void> setTheme(ThemeMode newTheme) async {

    // CHANGE APP THEME IMMEDIATELY
    themeMode.value = newTheme;

    // SAVE USER'S SELECTION
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'appTheme',
      newTheme.name,
    );
  }
}