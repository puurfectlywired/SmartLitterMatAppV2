

import 'package:flutter/material.dart';

import '../pages/home.dart';

// import '../widgets/app_bar.dart';
// import '../widgets/drawer.dart';
// import '../widgets/bottom_nav_bar.dart';

////////////////////////////////////////////LOGIN PAGE//////////////////////////////////////////
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
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
