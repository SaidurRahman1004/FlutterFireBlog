import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'auth/signup_screen.dart';
import 'home/home_screen.dart';
import 'auth/login_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: StreamBuilder(stream: AuthService().authStateChanges,                   ////// Listening to the authStateChanges stream from the AuthService
          builder: (_,snap){
        if(snap.connectionState==ConnectionState.waiting){
          return Center(child: SpinKitCircle(
            color: Colors.blue,
            size: 40,
          ),);
        }if(snap.hasData){
          return HomeScreen();
        }
        return LoginOrSignupScreen();

          }),
    );
  }
}


// This widget will toggle between the login and sign-up pages. //LoginOrSignupScreen
class LoginOrSignupScreen extends StatefulWidget {
  const LoginOrSignupScreen({super.key});

  @override
  State<LoginOrSignupScreen> createState() => _LoginOrSignupScreenState();
}

class _LoginOrSignupScreenState extends State<LoginOrSignupScreen> {
  bool showLoginPage = true;                      //Initially, we will show the login page

  void togglePages() {                          //This function will change the page when called
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginScreen(onTapToSignUp: togglePages);                     //Loading the login screen and passing the function to toggle
    } else {
      return SignUpScreen(onTapToLogin: togglePages);                   //Loading the sign-up screen and passing the function to toggle
    }
  }
}
