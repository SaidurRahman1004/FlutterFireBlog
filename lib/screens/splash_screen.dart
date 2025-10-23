import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // এই পেজটি তৈরি হওয়ার সাথে সাথেই টাইমার শুরু হবে
    Timer(const Duration(seconds: 3), _checkAuthStatus);
  }

  void _checkAuthStatus() {

    final user = FirebaseAuth.instance.currentUser;    //ccheak Current User

    if (user != null) {
      // ব্যবহারকারী লগইন করা থাকলে FeedScreen-এ পাঠানো হবে
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  HomeScreen()),
      );
    } else {
      // ব্যবহারকারী লগইন করা না থাকলে LoginScreen-এ পাঠানো হবে
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //Wonderfull Gradient Background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // অ্যাপের আইকন বা লোগো
            Icon(
              Icons.article_rounded,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            // অ্যাপের নাম
            Text(
              "FlutterFire Blog",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 50),
            // লোডিং অ্যানিমেশন
            SpinKitCircle(
              color: Colors.white,
              size: 40.0,
            ),
            SizedBox(width: double.infinity),

          ],
        ),
      ),
    );
  }
}
