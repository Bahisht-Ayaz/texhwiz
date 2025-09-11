import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_eproject/city.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Update());
}

class Update extends StatelessWidget {
  const Update({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UPDATE PROFILE',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MyHomePage(title: 'Update Profile'),
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
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
   TextEditingController genderController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  User? currentUser;
  Map<String, dynamic> userData = {}; // Store user data for the form

  @override
  void initState() {
    super.initState();
    currentUser = auth.currentUser;
    fetchUserData(); // Fetch user data from Firestore when the page loads
  }

  // Fetch data from Firestore based on the current user's email
  Future<void> fetchUserData() async {
    if (currentUser != null) {
      String email = currentUser!.email!;
      try {
        // Search for the user's data in Firestore collection
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('User') // Ensure the collection exists
            .where('Email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            userData = {
              'Name': querySnapshot.docs[0]['Name'],
              'Email': querySnapshot.docs[0]['Email'],
              'Gender': querySnapshot.docs[0]['Gender'],
              'Contactno': querySnapshot.docs[0]['Contactno'],
            };

            // Populate the text controllers with the fetched data
            nameController.text = userData['Name'];
            emailController.text = userData['Email'];
            genderController.text = userData['Gender'];
            phoneController.text = userData['Contactno'];
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  // Update Firestore with the new data from the form
  Future<void> updateUserData() async {
  if (currentUser != null) {
    try {
      String email = currentUser!.email!;

      // Fetch the document based on the email (same as in fetchUserData)
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('Email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        // Get the document reference from the query snapshot
        DocumentReference docRef = querySnapshot.docs[0].reference;
        print(querySnapshot.size);
        // Update the document using the reference
        await docRef.update({
          'Name': nameController.text,
          'Email': emailController.text,
          'Gender': genderController.text,
          'Contactno': phoneController.text,
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        // Document not found case
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found. Please try again.')),
        );
      }
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile. Please try again.')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (builder) => City()),
            );
          },
        ),
        backgroundColor: Color(0xFF1E88E5),
        elevation: 4,
        centerTitle: true,
      ),
      body: Container(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: 1.0,
                    child: Text(
                      "Update Profile",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  buildTextField(
                    
                    controller: nameController,
                    hintText: 'Enter your name',
                    icon: Icons.person,
                    obscureText: false,
                    
                  ),
                  SizedBox(height: 20),
                  buildTextField(
                    controller: emailController,
                    hintText: 'Enter your email',
                    icon: Icons.email,
                    obscureText: false,
                    
                  ),
                     SizedBox(height: 20),
                  buildTextField(
                    controller: genderController,
                    hintText: 'Enter your Gender',
                    icon: Icons.phone,
                    obscureText: false,
                  ),
                 
                  SizedBox(height: 20),
                  buildTextField(
                    controller: phoneController,
                    hintText: 'Enter your phone number',
                    icon: Icons.phone,
                    obscureText: false,
                  ),
                 
                  SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: updateUserData,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      iconColor: Colors.black,
                      backgroundColor:  Color(0xFF1E88E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                    ),
                    label: Text(
                      "Update Profile",
                      style: TextStyle(color :Colors.white ,fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool obscureText,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: 350),
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.black.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintText: hintText,
          hintStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          suffixIcon: Icon(icon, color: Colors.black),
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}
