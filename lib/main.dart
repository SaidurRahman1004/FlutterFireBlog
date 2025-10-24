import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_fire_app/screens/auth/login_screen.dart';
import 'package:flutter_fire_app/screens/auth_gate.dart';
import 'package:flutter_fire_app/screens/splash_screen.dart';
import 'package:flutter_fire_app/widgets/blog_post_card.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:" FlutterFire Blog",
      home: AuthGate(),   //AuthGate
    );
  }
}
















