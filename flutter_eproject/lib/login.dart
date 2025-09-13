import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_eproject/Signin.dart';
import 'package:flutter_eproject/pet_owner.dart';
import 'package:flutter_eproject/forgotpassword.dart';
import 'package:flutter_eproject/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'firebase_options.dart';

void main() {
  runApp(const login());
}

class login extends StatelessWidget {
  const login({super.key});

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
  FirebaseAuth auth = FirebaseAuth.instance;
  void mera_kaam() async {
    try {
      GoogleSignInAccount? account = await GoogleSignIn(
        clientId: "1086543133004-oircvhgjc43b0aqvctivrpq8i4bk55ae.apps.googleusercontent.com").signIn();
        GoogleSignInAuthentication authenticate = await account!.authentication;
        AuthCredential cred = await GoogleAuthProvider.credential(
          accessToken: authenticate.accessToken,
          idToken: authenticate.idToken
        );
        auth.signInWithCredential(cred);
        print(auth.currentUser!.displayName);
        Navigator.push(context, MaterialPageRoute(builder: (builder)=>HomePage()));
    }catch(e){
      print("$e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }
  TextEditingController b = TextEditingController();
  TextEditingController c = TextEditingController();

  void login_func() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential ca = await auth.signInWithEmailAndPassword(
          email: b.text, password: c.text);
      Navigator.push(context, MaterialPageRoute(builder: (a) => HomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("$e"),
        backgroundColor: Colors.red, // Green background color
    behavior: SnackBarBehavior.floating, // Optional: Makes the SnackBar float
    duration: Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          Colors.transparent, // Transparent background to see the image
      body: Stack(
        children: [
        // Background Image
          Positioned.fill(
            child: Image.asset(
              'image.png', // Replace with your image asset
              fit: BoxFit.cover, // Cover the entire screen
            ),
          ),

          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur values
              child: Container(
                color: Colors.black.withOpacity(0.2), // Optional overlay color
              ),
                ),
          ),

          // Glassmorphism Form
          Center(
            child: Container(
              padding: EdgeInsets.all(
                  screenWidth * 0.08), // Use percentage-based padding
              width: screenWidth *
                  0.9, // Set width as a percentage of screen width
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2), // Glass effect
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LOGIN ',
                      style: TextStyle(
                        fontSize: screenWidth * 0.08, // Scalable font size
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02), // Scalable spacing
                    // Email Input Field
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.white
                                    .withOpacity(0.7))), // White border
                      ),
                      child: TextField(
                        controller: b,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold), // White label color
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold), // White hint text color
                        ),
                        style: TextStyle(
                            color: Colors.white), // White input text color
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02), // Scalable spacing
                    // Password Input Field

                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.white
                                    .withOpacity(0.7))), // White border
                      ),
                      child: TextField(
                        controller: c,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold), // White label color
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold), // White hint text color
                        ),
                        style: TextStyle(
                            color: Colors.white), // White input text color
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Remember Me & Forgot Password
                   Center(
  child: TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => forgotpass()),
      );
    },
    child: Text(
      'Forgot password?',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
        SizedBox(height: screenHeight * 0.02),
// Login Button
SizedBox(
  width: screenWidth * 0.8, // Set a fixed width for consistency
  child: ElevatedButton(
    onPressed: login_func,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.yellow,
      padding: EdgeInsets.symmetric(vertical: 15), // Adjust padding for height
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
    ),
    child: Text(
      'Login',
      style: TextStyle(
        color: Colors.black,
        fontSize: screenWidth * 0.04, // Scalable font size
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
SizedBox(height: 20), // Adds a gap between buttons
// Sign Up Button
SizedBox(
  width: screenWidth * 0.8, // Same fixed width as the Login button
  child: ElevatedButton(
    onPressed: mera_kaam,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.yellow,
      padding: EdgeInsets.symmetric(vertical: 15), // Adjust padding for height
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center the icon and text
      children: [
        Icon(
          FontAwesomeIcons.google, // You can replace this with a Google icon or another relevant icon
          color: Colors.red,
          size: screenWidth * 0.06, // Scalable icon size
        ),
        SizedBox(width: 10), // Space between the icon and the text
        Text(
          'Sign Up with Google',
          style: TextStyle(
            color: Colors.black,
            fontSize: screenWidth * 0.04, // Scalable font size
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),


                    SizedBox(height: screenHeight * 0.02),
                    // Register Link
                    TextButton(
                      onPressed: () {},
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (builder) => Signin()));
                        },
                        child: Text(
                          "Don't have Account?",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build input fields
  Widget _buildInputField({required String label, required bool obscureText}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.white.withOpacity(0.5))),
      ),
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
