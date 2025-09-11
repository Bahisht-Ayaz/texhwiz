import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_eproject/Signin.dart';
import 'package:flutter_eproject/login.dart';
import 'firebase_options.dart';

void main(){


  runApp(const forgotpass());
}

class forgotpass extends StatelessWidget {
  const forgotpass({super.key});

  // This widget is the root of your application.
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

TextEditingController  b =TextEditingController();

void  Password_link(){
try {
FirebaseAuth.instance.sendPasswordResetEmail(email:b.text);
Navigator.push(context, 
MaterialPageRoute(builder: (Builder) => Signin()));
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"),backgroundColor: Colors.red,));
}  
}
 

  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
    
      body: Stack(
        children: [
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
          
          
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300,),
              child: Container(
                margin: const EdgeInsets.only(top: 80, bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2), 
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Form(
                
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     
                      const Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                    
                      TextFormField(
                      
                        controller: b,
                        decoration: const InputDecoration(
                          labelText: "Email",
                        
                          labelStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(Icons.email,color: Colors.white,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white))
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter your email.";
                          }
                        
                        },
                      ),
                      const SizedBox(height: 10),
                      
                      
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                        ),
                        onPressed: Password_link,
                        child: const Text(
                          "Send Reset Link",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (builder)=>login())); 
                        },
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }
}
