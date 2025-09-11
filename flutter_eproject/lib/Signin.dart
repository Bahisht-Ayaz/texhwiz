import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_eproject/city.dart';
import 'package:flutter_eproject/login.dart';
import 'firebase_options.dart';


void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const Signin());
}

class Signin extends StatelessWidget {
  const Signin({super.key});

  
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

  TextEditingController a = TextEditingController();
  TextEditingController b = TextEditingController();
  TextEditingController c = TextEditingController();
  TextEditingController d = TextEditingController();
  TextEditingController e = TextEditingController();

  // Dropdown ke liye variable
  String? selectedRole;

  void register_func() async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      FirebaseAuth auth = FirebaseAuth.instance;

      UserCredential user = await auth.createUserWithEmailAndPassword(
        email: b.text,
        password: c.text,
      );

      // Firestore me data bhejna
      await db.collection("User").add({
        "Name": a.text,
        "Email": b.text,
        "Gender": d.text,
        "Contactno": e.text,
        "Role": selectedRole, // dropdown ka data bhi save
      });

      if (auth.currentUser != null) {
        await auth.currentUser?.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User Register Successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'image.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.08),
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Name
                    _buildTextField("Name", a, false),
                    SizedBox(height: screenHeight * 0.02),

                    // Email
                    _buildTextField("Email", b, false),
                    SizedBox(height: screenHeight * 0.02),

                    // Password
                    _buildTextField("Password", c, true),
                    SizedBox(height: screenHeight * 0.02),

                    // Gender
                    _buildTextField("Gender", d, false),
                    SizedBox(height: screenHeight * 0.02),

                    // Contact
                    _buildTextField("Contact no:", e, false),
                    SizedBox(height: screenHeight * 0.02),

                    // Dropdown (Role)
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      dropdownColor: Colors.black87,
                      decoration: InputDecoration(
                        labelText: "Select Role",
                        labelStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.7)),
                        ),
                      ),
                      items: [
                        "Pet Owner",
                        "Veterinarian",
                        "Shelter Admin",
                      ].map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(
                            role,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // SignUp Button
                    ElevatedButton(
                      onPressed: register_func,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
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

  Widget _buildTextField(
      String label, TextEditingController controller, bool obscure) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.7))),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          border: InputBorder.none,
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
