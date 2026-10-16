import 'package:flutter/material.dart';

import '../pages/home.dart';

////////////////////////////////////////MY APP BAR//////////////////////////////////////////
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.title,
    this.showLogo = false,
    this.showBackButton = true,
    this.showHamburgerMenu = true,
    });

  final String title;
  final bool showLogo;
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
        
        //prevents automatic back arrow - for home page
        automaticallyImplyLeading: false,

        //LOGO & BACK BUTTON
        leading: showLogo
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/cat_icon.png',
                width: 90,
                height: 90,
              ),
            )
          : showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const HomePage(title: 'Puurfectly WIRED'),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                },
              )
            : null,
        
        //TITLE
        title: Text(title),
        centerTitle: (true),

        //HAMBURGER MENU
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
  Size get preferredSize => const Size.fromHeight(60);
}
