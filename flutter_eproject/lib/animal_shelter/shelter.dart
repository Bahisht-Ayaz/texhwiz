import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_eproject/petownwer/addpet.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_eproject/Contactus.dart';
import 'package:flutter_eproject/Signin.dart';
import 'package:flutter_eproject/Updateprofile.dart';
import 'package:flutter_eproject/login.dart';
import 'package:flutter_eproject/rateus.dart';
import 'package:flutter_eproject/feedback.dart'; // 👈 feedback page import karo

class Shelter extends StatefulWidget {
  @override
  _FirestoreGridViewState createState() => _FirestoreGridViewState();
}

class _FirestoreGridViewState extends State<Shelter> {
  Map<String, dynamic> userData = {};
  String username = "";
  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> fetchData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String email = currentUser.email!;
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Shelter')
            .where('Email', isEqualTo: email)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            userData = {
              'Name': querySnapshot.docs[0]['Name'],
              'Email': querySnapshot.docs[0]['Email'],
            };
            username = userData['Name'];
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void _updateProfilePicture(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo =
                    await picker.pickImage(source: ImageSource.camera);
                if (photo != null) {
                  _updatePhoto(File(photo.path));
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  _updatePhoto(File(image.path));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, FirebaseAuth auth) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                auth.signOut();
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => login()),
                );
              },
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _updatePhoto(File imageFile) {
    print('Image Path: ${imageFile.path}');
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PetsCare',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (auth.currentUser != null)
            IconButton(
              onPressed: () {
                _showLogoutDialog(context, auth);
              },
              icon: Icon(Icons.logout),
              color: Colors.white,
            ),
        ],
        backgroundColor: Color(0xFF1E88E5),
        elevation: 4,
        centerTitle: true,
      ),

      // ✅ Feedback Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1E88E5),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Pets()),
          );
        },
        child: const Icon(Icons.feedback, color: Colors.white),
      ),

      drawer: auth.currentUser == null
          ? Drawer(
              child: ListView(children: [
                ListTile(
                  leading: Icon(Icons.login, color: Colors.black),
                  title: Text("Login", style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => login()),
                    );
                  },
                ),
              ]),
            )
          : Drawer(
              child: ListView(
                children: [
                  UserAccountsDrawerHeader(
                    currentAccountPicture: GestureDetector(
                      onTap: () {
                        _updateProfilePicture(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        backgroundImage: currentUser?.photoURL != null
                            ? NetworkImage(currentUser!.photoURL!)
                            : null,
                        child: currentUser?.photoURL == null
                            ? Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    accountName: Text(
                      auth.currentUser != null ? username : 'Loading...',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    accountEmail: Text(
                      auth.currentUser != null
                          ? auth.currentUser!.email!
                          : 'Loading...',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  // ListTile(
                  //   leading: Icon(Icons.contact_page, color: Colors.black),
                  //   title: Text("Pet Profile",
                  //       style: TextStyle(color: Colors.black)),
                  //   onTap: () {
                  //     // Navigator.push(
                  //     //   context,
                  //     //   MaterialPageRoute(builder: (context) => Pets()),
                  //     // );
                  //   },
                  // ),
                  // ListTile(
                  //   leading: Icon(Icons.person, color: Colors.black),
                  //   title: Text("Update Profile",
                  //       style: TextStyle(color: Colors.black)),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => Update()),
                  //     );
                  //   },
                  // ),
                  ListTile(
                    leading: Icon(Icons.rate_review, color: Colors.black),
                    title:
                        Text("Rate us", style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Rateus()),
                      );
                    },
                  ),
                  // ListTile(
                  //   leading: Icon(Icons.rate_review, color: Colors.black),
                  //   title:
                  //       Text("Rate us", style: TextStyle(color: Colors.black)),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => Rateus()),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Shelter').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No data available"));
          }

          final cities = snapshot.data!.docs.map((doc) {
            return {
              "Name": doc["Name"],
              "Image": doc["Image"],
            };
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 0.75,
              ),
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                return buildCard(
                  context: context,
                  name: city["Name"]!,
                  
                  imageUrl: city["Image"]!,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildCard({
    required BuildContext context,
    required String name,
    
    required String imageUrl,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Image.network(imageUrl,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
