
import 'package:flutter/material.dart';

import '../views/home.dart';

////////////////////////////////////////MY APP BAR//////////////////////////////////////////
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.title,
    this.showAppLogo = false,
    this.showBackButton = true,
    this.showHamburgerMenu = true,
  });

  final String title;
  final bool showAppLogo;
  final bool showBackButton;
  final bool showHamburgerMenu;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      toolbarHeight: 90,
      leadingWidth: 60,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,

      // PREVENTS AUTOMATIC BACK ARROW
      automaticallyImplyLeading: false,

      // BACK BUTTON
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                      ) =>
                          const HomePage(
                        title: 'Puurfectly WIRED',
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              },
            )
          : null,

      // APP LOGO OR PAGE TITLE
      title: showAppLogo
          ? Image.asset(
              'assets/images/PUUR_v4.png',
              height: 55,
              fit: BoxFit.contain,
              color: Theme.of(context).colorScheme.onSurface,
            )
          : Text(title),

      centerTitle: true,

      // HAMBURGER MENU
      actions: showHamburgerMenu
          ? [
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  );
                },
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
