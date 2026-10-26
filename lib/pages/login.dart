
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_litter_mat/pages/user_registration/create_username.dart';

//pages
import '../pages/home.dart';

//services
import '../services/auth_service.dart';


////////////////////////////////////////////LOGIN PAGE//////////////////////////////////////////
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

///////////////////////////////////////////LOGIN PAGE//////////////////////////////////////////
class _LoginPageState extends State<LoginPage> {

  //controllers retrieve info from email/password text fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  //firebase authentication
  final AuthService _authService = AuthService();

  bool invalidLogin = false;
  bool isLoggingIn = false;
  String errorMessage = 'Invalid email or password';

  // VALIDATE EMAIL FORMAT
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.(com|ca)$',    //temp?? what about .yahoo?
      caseSensitive: false,
    );

  return emailRegex.hasMatch(email);
}


// LOGIN USING FIREBASE
Future<void> login() async {

  // PREVENT MULTIPLE LOGIN ATTEMPTS
  if (isLoggingIn) return;

  final input = emailController.text.trim();

  // VALIDATE EMAIL FIRST
  if (input.contains('@') && !isValidEmail(input)) {
    setState(() {
      invalidLogin = true;
      errorMessage = 'Please enter a valid email address';
    });
    return;
  }

  setState(() {
    isLoggingIn = true;
    invalidLogin = false;
  });

  try {

    // CHECK EMAIL AND PASSWORD WITH FIREBASE
    await _authService.loginUser(
      email: input,
      password: passwordController.text,
    );

    if (!mounted) return;

    // NAVIGATE TO HOME PAGE AFTER SUCCESSFUL LOGIN
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

  } on FirebaseAuthException catch (e) {

    if (!mounted) return;

    setState(() {
      invalidLogin = true;

      if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email address';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many attempts. Please try again later';
      } else {
        errorMessage = 'Invalid email or password';
      }
    });

  } catch (e) {

    if (!mounted) return;

    setState(() {
      invalidLogin = true;
      errorMessage = 'Unable to log in. Please try again';
    });

  } finally {

    if (mounted) {
      setState(() {
        isLoggingIn = false;
      });
    }
  }
}


  //login using firebase
  // Future<void> login() async {

  //   //prevent multiple login attempts
  //   if (isLoggingIn) return;

  //   setState(() {
  //     isLoggingIn = true;
  //     invalidLogin = false;
  //   });

  //   try {

  //     //check email and password with firebase
  //     await _authService.loginUser(
  //       email: emailController.text.trim(),
  //       password: passwordController.text,
  //     );

  //     if (!mounted) return;

  //     //navigate to home page after successful login
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       PageRouteBuilder(
  //         pageBuilder: (context, animation, secondaryAnimation) =>
  //             const HomePage(title: 'Puurfectly WIRED'),
  //         transitionDuration: Duration.zero,
  //         reverseTransitionDuration: Duration.zero,
  //       ),
  //       (route) => false,
  //     );

  //   } on FirebaseAuthException catch (e) {

  //     if (!mounted) return;

  //     setState(() {
  //       invalidLogin = true;

  //       if (e.code == 'invalid-email') {
  //         errorMessage = 'Please enter a valid email address';
  //       } else if (e.code == 'too-many-requests') {
  //         errorMessage = 'Too many attempts. Please try again later';
  //       } else {
  //         errorMessage = 'Invalid email or password';
  //       }
  //     });

  //   } catch (e) {

  //     if (!mounted) return;

  //     setState(() {
  //       invalidLogin = true;
  //       errorMessage = 'Unable to log in. Please try again';
  //     });

  //   } finally {

  //     if (mounted) {
  //       setState(() {
  //         isLoggingIn = false;
  //       });
  //     }
  //   }
  // }

  //dispose controllers
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   toolbarHeight: 60,
      //   title: const Text('put logo here'),
      // ),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Logo above title
              Image.asset(
                'assets/images/PUUR_v4.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
                color: Theme.of(context).colorScheme.onSurface,

              ),

              SizedBox(height: 20),

              Text(
                'Welcome to a life with plenty of PUURs',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              ),

              SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // NEED AN ACCOUNT?
                  Text(
                    'Need an account?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  SizedBox(width: 8),

                  // REGISTER BUTTON
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              const CreateUsername(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),

                        SizedBox(width: 6),

                        Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),


              SizedBox(height: 100),

              //email field - chnage to accept either email or username later
              SizedBox(
                width: 300,
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              SizedBox(height: 30),

              //password field
              SizedBox(
                width: 300,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              SizedBox(height: 30),

              //invalid login message
              if (invalidLogin)
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),

              if (invalidLogin)
                const SizedBox(height: 30),

              //login button
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: isLoggingIn ? null : login,
                  child: Text(
                    isLoggingIn ? 'Logging In...' : 'Login',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
