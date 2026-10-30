
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
//import 'package:google_fonts/google_fonts.dart';

import 'login.dart';
import 'user_registration/create_username.dart';

///////////////////////////////////////////WELCOME PAGE//////////////////////////////////////////
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

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
  }


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

          // SUBTLE BACKGROUND GRADIENT
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // BUTTONS ON TOP OF VIDEO
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                  Image.asset(
                    'assets/images/PUUR_v4.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),

                const SizedBox(height: 150),

                // LOGIN BUTTON
                SizedBox(
                  width: 200,
                  height: 45,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F0F0),
                      foregroundColor: const Color(0xFF29252A),
                      elevation: 4,
                      shadowColor: Colors.black.withValues(alpha:0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),

                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const LoginPage(),
                        ),
                      );
                    },

                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // REGISTER BUTTON
                SizedBox(
                  width: 200,
                  height: 45,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFA0BD),
                      foregroundColor: const Color(0xFF29252A),
                      elevation: 4,
                      shadowColor: Colors.black.withValues(alpha:0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),

                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const CreateUsername(),
                        ),
                      );
                    },

                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

