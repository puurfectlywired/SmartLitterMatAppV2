
import 'package:flutter/material.dart';

// GLOBAL VARIABLES
import '../other/global_variables.dart';

// THEME
import '../theme/theme_controller.dart';

// PAGES
import 'settings/login_info.dart';

// WIDGETS
import '../widgets/app_bar.dart';
import '../widgets/drawer.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/selection_button.dart';


////////////////////////////////////////////SETTINGS PAGE//////////////////////////////////////////
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}


////////////////////////////////////////////SETTINGS PAGE STATE//////////////////////////////////////////
class _SettingsPageState extends State<SettingsPage> {

  ThemeMode selectedTheme = ThemeController.themeMode.value;


  //////////////////////////////////////////CHANGE THEME//////////////////////////////////////////
  void changeTheme(ThemeMode newTheme) {
    setState(() {
      selectedTheme = newTheme;
    });

    ThemeController.setTheme(newTheme);
  }

  ////////////////////////////////////////////INSTANT NAVIGATION//////////////////////////////////////////
  void navigateTo(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  ////////////////////////////////////////////BUILD PAGE//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: const MyAppBar(
        title: 'Settings',
        showBackButton: true,
        showHamburgerMenu: true,
      ),

      endDrawer: const MyDrawer(),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              ////////////////////////////////////////////APPEARANCE//////////////////////////////////////////
              _sectionHeading('Appearance'),

              const SizedBox(height: 20),

              _settingsContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'App Theme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // APP THEME SELECTION
                    Row(
                      children: [

                        Expanded(
                          child: SelectionButton(
                            label: 'Light',
                            selected: selectedTheme == ThemeMode.light,
                            onPressed: () {
                              changeTheme(ThemeMode.light);
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: SelectionButton(
                            label: 'Dark',
                            selected: selectedTheme == ThemeMode.dark,
                            onPressed: () {
                              changeTheme(ThemeMode.dark);
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: SelectionButton(
                            label: 'System',
                            selected: selectedTheme == ThemeMode.system,
                            onPressed: () {
                              changeTheme(ThemeMode.system);
                            },
                          ),
                        ),

                      ],
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 40),

              ////////////////////////////////////////////MEASUREMENTS//////////////////////////////////////////
              _sectionHeading('Measurements'),

              const SizedBox(height: 20),

              _settingsContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'Weight Units',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // WEIGHT UNIT SELECTION
                    Row(
                      children: [

                        Expanded(
                          child: SelectionButton(
                            label: 'Pounds',
                            selected: weightUnit == 'lb',

                            onPressed: () {
                              setState(() {
                                weightUnit = 'lb';
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: SelectionButton(
                            label: 'Kilograms',
                            selected: weightUnit == 'kg',

                            onPressed: () {
                              setState(() {
                                weightUnit = 'kg';
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: SelectionButton(
                            label: 'Grams',
                            selected: weightUnit == 'g',

                            onPressed: () {
                              setState(() {
                                weightUnit = 'g';
                              });
                            },
                          ),
                        ),

                      ],
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 40),

              ////////////////////////////////////////////ACCOUNT//////////////////////////////////////////
              _sectionHeading('Account'),

              const SizedBox(height: 20),

              _settingsContainer(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,

                  leading: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  title: const Text(
                    'Login Information',
                    style: TextStyle(fontSize: 16),
                  ),

                  trailing: const Icon(
                    Icons.chevron_right,
                  ),

                  onTap: () {
                    navigateTo(
                      const LoginInfoPage(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

            ],
          ),
        ),
      ),

      bottomNavigationBar: const MyBottomNavBar(),
    );
  }


  ////////////////////////////////////////////SECTION HEADING//////////////////////////////////////////
  Widget _sectionHeading(String title) {

    return Row(
      children: [

        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(width: 15),

        const Expanded(
          child: Divider(thickness: 1),
        ),

      ],
    );
  }


  ////////////////////////////////////////////SETTINGS CONTAINER//////////////////////////////////////////
  Widget _settingsContainer({
    required Widget child,
  }) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),

      child: child,
    );
  }
}
