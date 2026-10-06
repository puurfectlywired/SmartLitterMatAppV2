
import 'package:flutter/material.dart';

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 90,
        leadingWidth: 90,
        
        //LOGO
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
            ? null
            : const SizedBox(),
        
        //title
        title: Text(title),
        centerTitle: (true),

        //settings button
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
