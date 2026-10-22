
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  //login using firebase
  Future<void> login() async {

    //prevent multiple login attempts
    if (isLoggingIn) return;

    setState(() {
      isLoggingIn = true;
      invalidLogin = false;
    });

    try {

      //check email and password with firebase
      await _authService.loginUser(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      //navigate to home page after successful login
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

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 60,
        title: const Text('Puurfectly WIRED'),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                'Welcome to a Puurfectly WIRED\nlife with your furry friends!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              ),

              SizedBox(height: 100),

              //email field
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
