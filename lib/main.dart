//Author: Else
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
//import 'api/api_flutter.dart';

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

      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 255, 213, 231),
          brightness: Brightness.light,
          ), // colourScheme.fromSeed
      ),

      darkTheme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 255, 213, 231),
          brightness: Brightness.dark,
          ), // colourScheme.fromSeed
      ),

      home: const WelcomePage(),
    );
  }
}

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

/////////////////////////////////////////MY DRAWER//////////////////////////////////////////
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 275,
      child: Column(
        children: [
          //TITLE
          const SizedBox(
            height: 100,
            // child: Center(
            //   child: Text(
            //     'Menu',
            //     style: TextStyle(
            //       fontSize: 20,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
          ),

          //NAVIGATION SUBHEADING
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                const Text(
                  'NAVIGATION',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Divider(
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),

          //HOME BUTTON
          ListTile(
            //leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => 
                    const HomePage(title: 'Puurfectly WIRED'),
                ),
              );
            },
          ),

          //PROFILES BUTTON
          ListTile(
            //leading: const Icon(Icons.pets),
            title: const Text('Cats'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => 
                    const ProfilesPage(),
                ),
              );
            },
          ),

          //SETTINGS BUTTON
          ListTile(
            //leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => 
                    const SettingsPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          //NAVIGATION SUBHEADING
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                const Text(
                  'TEST',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Divider(
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),

          //TEST BUTTON
          // ListTile(
          //   //leading: const Icon(Icons.home),
          //   title: const Text('Test'),
          //   onTap: () {
          //     Navigator.pushReplacement(
          //       context,
          //       PageRouteBuilder(
          //         pageBuilder: (context, animation, secondaryAnimation) => 
          //           const TestPage(),
          //       ),
          //     );
          //   },
          // ),

          // Pushes Logout to the bottom
          const Spacer(),

          //LOGOUT BUTTON
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const LoginPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/////////////////////////////////////MY BOTTOM NAV BAR//////////////////////////////////////////////
class MyBottomNavBar extends StatelessWidget {
  const MyBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: const BorderRadius.vertical(          
          top: Radius.circular(50)
          ),
        child: BottomAppBar(
          color: Theme.of(context).colorScheme.inversePrimary,
          height: 90.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            
            //HOME
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.home,
                    size: 30,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => 
                        const HomePage(title: 'Puurfectly WIRED'),
                      ),
                    );
                  },
                ),
                const Text(
                  'Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            //CATS
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.pets,
                    size: 30,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => 
                        const ProfilesPage(),
                      ),
                    );
                  },
                ),
                const Text(
                  'Cats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            //ALERTS
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    size: 30,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => 
                        const AlertsPage(),
                      ),
                    );
                  },
                ),
                const Text(
                  'Alerts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            //SETTINGS
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    size: 30,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => 
                        const SettingsPage(),
                      ),
                    );
                  },
                ),
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        )
    );
  }
}





















/////////////////////////////////////GLOBAL VARIABLES///////////////////////////////////

//WEIGHT CONTROL
//default weight unit
String weightUnit = 'kg';

//store weight value
double storeWeight(double enteredWeight) {
  if (weightUnit == 'lb') {
    return enteredWeight / 2.20462;
    }
    else if (weightUnit == 'g') {
      return enteredWeight / 1000;
    }
    else {
      return enteredWeight;
    }
}

//convert weight unit, assuming internally stored as Kg
String displayWeight(double weightKg) {
  if (weightUnit == 'lb') {
    return '${(weightKg * 2.20462).toStringAsFixed(1)} lb';
  } 
  else if (weightUnit == 'g') {
    return '${(weightKg * 1000).toStringAsFixed(0)} g';
  } 
  else {
    return '${weightKg.toStringAsFixed(1)} kg';
  }
}

//PROFILE CONTROL
 List<CatProfile> catProfiles = []; // Example list of cat profiles

class CatProfile {
  final String name;
  final String age;
  final String breed;
  final String sex;
  final double weight;
  final String? imagePath;

  CatProfile({
    required this.name,
    required this.age,
    required this.breed,
    required this.sex,
    required this.weight,
    this.imagePath,
  });
}













































///////////////////////////////////////////WELCOME PAGE//////////////////////////////////////////
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

////////////////////////////////////////////LOGIN PAGE//////////////////////////////////////////
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

///////////////////////////////////////////HOME PAGE//////////////////////////////////////////
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

////////////////////////////////////////////PROFILES PAGE//////////////////////////////////////////
class ProfilesPage extends StatefulWidget {
  const ProfilesPage({super.key});

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

////////////////////////////////////////////NEW PROFILE PAGE//////////////////////////////////////////
class NewProfilePage extends StatefulWidget {
  const NewProfilePage({super.key});

  @override
  State<NewProfilePage> createState() => _NewProfilePageState();
}

////////////////////////////////////////////ALERTS PAGE//////////////////////////////////////////
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

////////////////////////////////////////////SETTINGS PAGE//////////////////////////////////////////
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}




///////////////////////////////////////////TEST PAGE///////////////////////////////////////////
// class TestPage extends StatefulWidget {
//   const TestPage({super.key});
//   @override
//   State<TestPage> createState() => _TestPage();
// }
// ////////////////////////////////////////////TEST PAGE////////////////////////////////
// class _TestPage extends State<TestPage> {
//   bool ledOn = false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const MyAppBar(
//         title: 'Test Page',
//         showLogo: true,
//         ),
//       endDrawer: const MyDrawer(),
//       body: Center(
//         child: Column (
//           children: [
//             SizedBox(height: 200),
//             ElevatedButton(
//               onPressed: () async {
//                 final newLedState = await ApiFlutter.setLed(!ledOn);
//                 setState(() {
//                   ledOn = newLedState;
//                 });
//               },
//               child: const Text('LED Toggle'),
//             ),
//             SizedBox(height: 50),
//             Icon(
//               Icons.pets,
//               size: 50,
//               color: ledOn
//                   ? Colors.red
//                   : Colors.grey,
//             ),
//           ]
//         ),
//       ),
//       bottomNavigationBar: const MyBottomNavBar(),
//     );
//   }
// }









////////////////////////////////////////////WELCOME PAGE STATE//////////////////////////////////////////
class _WelcomePageState extends State<WelcomePage> {

  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    _videoController =
        VideoPlayerController.asset('assets/videos/olive.mp4')
          ..initialize().then((_) {
            _videoController.setLooping(true);
            _videoController.setVolume(0);
            _videoController.play();

            setState(() {});
          });
    //testPiConnection();
  }

  // Future<void> testPiConnection() async {
  //   final buttonPressed = await ApiFlutter.getButtonStatus();
  //   print('Button pressed: $buttonPressed');
  // }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [

          // BACKGROUND VIDEO
          Positioned.fill(
            child: _videoController.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : Container(),
          ),

          // BUTTONS ON TOP OF VIDEO
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // LOGIN BUTTON
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => 
                          const LoginPage(),
                        ),
                      );
                    },
                    child: const Text('Log In'),
                  ),
                ),

                const SizedBox(height: 20),

                // REGISTER BUTTON
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 213, 230),
                    ),
                    onPressed: () {
                      // Go to register page
                    },
                    child: const Text('Register'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////LOGIN PAGE//////////////////////////////////////////
class _LoginPageState extends State<LoginPage> {
  
  //controllers retrieve info from username/password text fields
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool invalidLogin = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 60,
        title: const Text('Puurfectly WIRED'),
      ),
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Text(
              'Welcome to a Puurfectly WIRED\nlife with your furry friends!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
              )
            ),

            SizedBox(height: 70),

            //username field
            SizedBox(
              width: 300,
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            SizedBox(height: 30),

            // Password field
            SizedBox(
              width: 300,
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration:  InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            
            SizedBox(height: 30),

           //Invalid Login
           if (invalidLogin)
            const Text(
              'Invalid Login',
              style: TextStyle(
                color: Colors.red,
                //fontWeight: FontWeight.bold,
              )
            ),

            if (invalidLogin)
              const SizedBox(height: 30),

           // Login button
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {

                  //if username and password are correct, login button works
                  if (usernameController.text == 'cat' &&
                      passwordController.text == 'cat') {

                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const HomePage(title: 'Puurfectly WIRED'),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                      (route) => false,
                    );

                  } else {

                      setState((){
                        invalidLogin = true;
                      });
                    }

                }, //onPressed

                child: const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////HOME PAGE STATE//////////////////////////////////////////
class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: const MyAppBar(
        title: 'Puurfectly WIRED',
        showLogo: true,
        ),
      
      endDrawer: const MyDrawer(),
      
      body: Center(
        
      ),
      
      bottomNavigationBar: const MyBottomNavBar(),
    );
  }
}

/////////////////////////////////////////////PROFILES PAGE STATE//////////////////////////////////////////
class _ProfilesPageState extends State<ProfilesPage> {
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: 'Profiles'
        ),
      endDrawer: const MyDrawer(),
      
      body: catProfiles.isEmpty
        ? _buildEmptyPage()     //no cat profiles added
        : _buildProfilesList(), //cat profiles added

      bottomNavigationBar: const MyBottomNavBar(),
    );
  }

  //NO PROFILES YET PAGE
  Widget _buildEmptyPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pets,
            size: 80,
          ),

          const SizedBox(height: 20),

          const Text(
            'No cats added yet',
            style: TextStyle(
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 20),

          //ADD CAT BUTTON
          ElevatedButton(
            onPressed: () async {
              //opens new profile page and waits
              final newCat = await Navigator.push<CatProfile>(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const NewProfilePage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                if (newCat != null) {
                  setState(() {
                    catProfiles.add(newCat);
                  });
                }
            },
            child: const Text('Add Cat'),
          ),
        ],
      ),
    );
  }

  //WITH PROFILES ADDED
  Widget _buildProfilesList() {
  return ListView.builder(
    // +1 is for the add another cat button
    padding: const EdgeInsets.only(top: 12),
    itemCount: catProfiles.length + 1,
    itemBuilder: (context, index) {


      if (index == catProfiles.length) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () async {

              final newCat = await Navigator.push<CatProfile>(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const NewProfilePage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );

              //empty state remains the same
              if (newCat != null) {
                setState(() {
                  catProfiles.add(newCat);
                });
              }
            },
            child: const Text('Add Another Cat'),
          ),
        );
      }

      // Otherwise display the cat
      final cat = catProfiles[index];

      //info displayed on cat profile outside of full profile page
      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(15),
        ),

        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          // minTileHeight: 0,
          // minVerticalPadding: 0,

          leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 55,
            height: 55,
            child: cat.imagePath != null
                ? Image.file(
                    File(cat.imagePath!),
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.pets,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
          ),
          ),
          
          //CAT NAME
          title: Text(
            cat.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          //
          subtitle: Text(
            'Age: ${cat.age}   Weight: ${displayWeight(cat.weight)}',
          ),

          //ARROW
          trailing: const Icon(
            Icons.chevron_right,
          ),

          //CLICK INTO FULL PROFILE
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    FullProfilePage(cat: cat),
              ),
            );
          },
        ),
      );
    },
  );
}
}

///////////////////////////////////////////FULL PROFILE PAGE/////////////////////////////////////
class FullProfilePage extends StatelessWidget {
  
  final CatProfile cat;

  const FullProfilePage({
    super.key,
    required this.cat,
  });

@override
Widget build(BuildContext context) {
  return Scaffold(

    endDrawer: const MyDrawer(),

    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // CAT IMAGE + BACK BUTTON + MENU BUTTON
        Stack(
          children: [

            // CAT IMAGE
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[200],

              child: cat.imagePath == null
                  ? const Center(
                      child: Icon(
                        Icons.add_a_photo,
                        size: 60,
                        color: Colors.grey,
                      ),
                    )
                  : Image.file(
                      File(cat.imagePath!),
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
            ),

            // BACK BUTTON
            Positioned(
              top: 50,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // HAMBURGER MENU
            Positioned(
              top: 50,
              right: 10,
              child: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  );
                },
              ),
            ),
          ],
        ),

        // PROFILE INFORMATION
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // CAT NAME
                Center(
                  child: Text(
                    cat.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // BREED • SEX • AGE
                Center(
                  child: Text(
                    '${cat.breed} • ${cat.sex} • ${cat.age} years',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[700],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // EDIT PROFILE BUTTON
                Center(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Edit profile
                      },

                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                      ),

                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // DELETE PROFILE
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {

                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Profile'),
                            content: Text(
                              'Are you sure you want to delete ${cat.name}\'s profile?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text('Cancel'),
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldDelete == true) {
                        catProfiles.remove(cat);

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ProfilesPage(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                          (route) => false,
                        );
                      }
                    },
                    child: const Text('Delete Profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: const MyBottomNavBar(),
  );
}
}

/////////////////////////////////////////////NEW PROFILE PAGE STATE//////////////////////////////////////////
class _NewProfilePageState extends State<NewProfilePage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController sexController = TextEditingController();

  
  //PROFILE IMAGE
  File? selectedImage;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Open photo library
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    // User cancelled photo selection
    if (image == null) return;

    // Open cropping screen
    final CroppedFile? croppedImage =
      await ImageCropper().cropImage(
      sourcePath: image.path,

      aspectRatio: const CropAspectRatio(
        ratioX: 3, 
        ratioY: 2,
      ),

      uiSettings: [
        IOSUiSettings(
          title: 'Adjust Photo',
        ),

        AndroidUiSettings(
          toolbarTitle: 'Adjust Photo',
          lockAspectRatio: false,
        ),
      ],
    );

    // User cancelled cropping
    if (croppedImage == null) return;

    // Save cropped image
    setState(() {
      selectedImage = File(croppedImage.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: const MyAppBar(
        title: 'Create New Profile',
        showBackButton: false,
        showHamburgerMenu: false,
        ),
      
      //endDrawer: const MyDrawer(),
      
      body: SingleChildScrollView(
        child: Column(
        children: [

          //CAT IMAGE
          GestureDetector(
            onTap: pickImage,
            child: Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[200],

              child: selectedImage == null

                  // No image selected yet
                  ? const Center(
                      child: Icon(
                        Icons.add_a_photo,
                        size: 60,
                        color: Colors.grey,
                      ),
                    )

                  // Display selected image
                  : Image.file(
                      selectedImage!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          //PROFILE INFO
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                //name input
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                //breed input
                TextField(
                  controller: breedController,
                  decoration: const InputDecoration(
                    labelText: 'Breed',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                //age input
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                //sex input
                TextField(
                  controller: sexController,
                  decoration: InputDecoration(
                    labelText: 'Sex',
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                //weight input
                TextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    labelText: 'Current Weight ($weightUnit)',
                    border: const OutlineInputBorder(),
                  ),
                ),

                //const Spacer(),
                const SizedBox(height: 20),

                //CREATE PROFILE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final enteredWeight = double.tryParse(weightController.text);
                      if (enteredWeight == null) {
                        return;
                      }
                      final newCat = CatProfile(
                        name: nameController.text,
                        age: ageController.text,
                        breed: breedController.text,
                        sex: sexController.text,
                        weight: storeWeight(enteredWeight),
                        imagePath: selectedImage?.path,
                      );
                      Navigator.pop(context, newCat);
                    },
                    child: const Text('Create Profile'),
                  ),
                ),

                const SizedBox(height: 10),

                //CANCEL BUTTON
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      )
    );
    
  }
}

/////////////////////////////////////////////ALERTS PAGE STATE//////////////////////////////////////////
class _AlertsPageState extends State<AlertsPage> {
  
  String selectedAlertView = 'Overview';
  String selectedAlertProfile = 'General';
  
  //hardcoded demo weights
  final demoWeights = [
  10.8,
  10.7,
  10.7,
  10.6,
  10.5,
  10.4,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: const MyAppBar(
        title: 'Alerts'
        ),
      
      endDrawer: const MyDrawer(),
      
      body: Column(
        children: [

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),

            child: SizedBox(
              width: double.infinity,

              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                //padding: const EdgeInsets.all(4),

                decoration: BoxDecoration(
                  color: const Color(0xFFF9EEF2),
                  borderRadius: BorderRadius.circular(30),
                ),

                child: Row(
                  children: [
                    _alertTab('Overview'),
                    _alertTab('Recent'),
                    _alertTab('History'),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 90,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                _profileAlertButton(
                  name: 'General',
                  icon: Icons.sensors,
                ),

                _profileAlertButton(
                  name: 'Olive',
                  icon: Icons.pets,
                ),

                _profileAlertButton(
                  name: 'Winston',
                  icon: Icons.pets,
                ),

                _profileAlertButton(
                  name: 'Miso',
                  icon: Icons.pets,
                ),
              ],
            ),
          ),
        ],


      ),
    
      bottomNavigationBar: const MyBottomNavBar()
      );
  }

Widget _alertTab(String title) {
  final bool selected = selectedAlertView == title;

  return Expanded(
    child: GestureDetector(
      onTap: () {
        setState(() {
          selectedAlertView = title;
        });
      },

      child: Container(
        height: double.infinity,
        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFA6C9)
              : Colors.transparent,

          borderRadius: BorderRadius.circular(30),
        ),

        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: selected
                ? Colors.black
                : Colors.grey,
          ),
        ),
      ),
    ),
  );
}

Widget _profileAlertButton({
  required String name,
  required IconData icon,
}) {
  final bool selected = selectedAlertProfile == name;

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedAlertProfile = name;
      });
    },

    child: Container(
      width: 80,

      child: Column(
        children: [

          Container(
            width: 55,
            height: 55,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? const Color(0xFFF2D5DD)
                  : Colors.grey[200],

              border: selected
                  ? Border.all(
                      color: const Color(0xFFB95F79),
                      width: 3,
                    )
                  : null,
            ),

            child: Icon(
              icon,
              size: 27,
              color: selected
                  ? const Color(0xFFB95F79)
                  : Colors.grey,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

}

////////////////////////////////////////////SETTINGS PAGE STATE//////////////////////////////////////////
class _SettingsPageState extends State<SettingsPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: const MyAppBar(
        title: 'Settings'
        ),
      endDrawer: const MyDrawer(),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            'Weight Units',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          SegmentedButton<String>(
            segments: const [

              ButtonSegment<String>(
                value: 'lb',
                label: Text('Pounds'),
              ),

              ButtonSegment<String>(
                value: 'kg',
                label: Text('Kilograms'),
              ),

              ButtonSegment<String>(
                value: 'g',
                label: Text('Grams'),
              ),

            ],


            selected: {weightUnit},

            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                weightUnit = newSelection.first;
              });
            },
          ),

        ],
      ),

      bottomNavigationBar: const MyBottomNavBar(),
    );
  }
}