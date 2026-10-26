
import 'package:flutter/material.dart';

//import '../pages/cat_profiles/new_profile_01.dart';

// CANCEL THE ENTIRE CAT REGISTRATION PROCESS
void cancelCatRegistration(BuildContext context) {

  Navigator.of(context).popUntil((route) {
    return route.settings.name != '/cat-registration';
  });
}

// CREATE THE REGISTRATION ROUTE
Route<T> catRegistrationRoute<T>({
  required Widget page,
}) {
  return PageRouteBuilder<T>(
    settings: const RouteSettings(
      name: '/cat-registration',
    ),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}
