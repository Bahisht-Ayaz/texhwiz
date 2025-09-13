import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_eproject/Signin.dart';
import 'package:flutter_eproject/pet_owner.dart';
import 'package:flutter_eproject/login.dart';
import 'firebase_options.dart';
import 'package:flutter_eproject/feedback.dart';
import 'package:flutter_eproject/Contactus.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


@override
void initState(){
  super.initState();
  Timer(Duration(seconds: 5), () => Navigator.pushReplacement(context,
   MaterialPageRoute(builder: (a)=>HomePage())));
}

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      backgroundColor: Colors.blue[100], // Background color for the splash screen
      body: Center(
        child: Lottie.asset(
          "assets/images/PetCare.json",width: 200, height: 200
        ),
      ),
    );
  }
}