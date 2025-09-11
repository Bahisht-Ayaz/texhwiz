
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_eproject/Contactus.dart';
import 'package:flutter_eproject/Signin.dart';
import 'package:flutter_eproject/Updateprofile.dart';
import 'package:flutter_eproject/city.dart';
import 'package:flutter_eproject/login.dart';
import 'package:flutter_eproject/rateus.dart';

import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';


class City extends StatefulWidget {
  @override
  _FirestoreGridViewState createState() => _FirestoreGridViewState();
}

class _FirestoreGridViewState extends State<City> {
  Map<String, dynamic> userData = {};
  String username = "";

  Future<void> fetchData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String email = currentUser.email!;

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


            };

            // Populate the text controllers with the fetched data
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
    fetchData(); // Fetch data when the widget is initialized
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
              Navigator.pop(context); // Close the modal
              final XFile? photo = await picker.pickImage(source: ImageSource.camera);
              if (photo != null) {
                _updatePhoto(File(photo.path));
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Choose from Gallery'),
            onTap: () async {
              Navigator.pop(context); // Close the modal
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
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
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("Cancel",style: TextStyle(color: Colors.red),),
          ),
          TextButton(
            onPressed: () {
              auth.signOut(); // Perform logout
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => login()),
              ); // Redirect to login page
            },
            child: Text("Logout",style: TextStyle(color: Colors.red),),
          ),
        ],
      );
    },
  );
}
void _updatePhoto(File imageFile) {
  // Here you can upload the file to a server or update it locally
  print('Image Path: ${imageFile.path}');
  // Add your logic to update the profile picture
}
  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Citiguide',
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
                _showLogoutDialog(context, auth); // Call the logout dialog
              },
              icon: Icon(Icons.logout),
              color: Colors.white,
            ),
        ],
        backgroundColor: Color(0xFF1E88E5),
        elevation: 4,
        centerTitle: true,
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
            // Add functionality to allow users to change their profile picture
            _updateProfilePicture(context);
          },
          child: CircleAvatar(
            backgroundColor: Colors.black,
            backgroundImage: currentUser?.photoURL != null
                ? NetworkImage(currentUser!.photoURL!) // User's photo
                : null,
            child: currentUser?.photoURL == null
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    accountName: Text(
                      auth.currentUser != null ? username : 'Loading...',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    accountEmail: Text(
                      auth.currentUser != null
                          ? auth.currentUser!.email!
                          : 'Loading...',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                    ListTile(
        leading: Icon(Icons.contact_page, color: Colors.black),
        title: Text("Contact Us", style: TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Contact()),
          );
        },
      ),
      // Update Profile
      ListTile(
        leading: Icon(Icons.person, color: Colors.black),
        title: Text("Update Profile", style: TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Update()),
          );
        },
      ),
      // Other List Items
      
      Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Text("Profile", style: TextStyle(color: Colors.grey)),
      ),
      Divider(color: Colors.grey, indent: 10, endIndent: 10),
      ListTile(
        leading: Icon(Icons.place, color: Colors.black),
        title: Text("Visited Malls", style: TextStyle(color: Colors.black)),
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => VisitedPlacesScreen()),
          // );
        },
      ),
      ListTile(
        leading: Icon(Icons.place, color: Colors.black),
        title: Text("Visited Restaurants", style: TextStyle(color: Colors.black)),
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => Visitedrestaurants()),
          // );
        },
      ),
       ListTile(
        leading: Icon(Icons.place, color: Colors.black),
        title: Text("Visited Amusement Parks", style: TextStyle(color: Colors.black)),
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => Visitedamus()),
          // );
        },
      ),
      ListTile(
        leading: Icon(Icons.place, color: Colors.black),
        title: Text("Attractive Places", style: TextStyle(color: Colors.black)),
      ),
      Divider(color: Colors.grey, indent: 10, endIndent: 10),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Text("Communicate", style: TextStyle(color: Colors.grey)),
      ),
      ListTile(
        leading: Icon(Icons.rate_review, color: Colors.black),
        title: Text("Rate us", style: TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Rateus()),
          );
        },
      ),
                ],
              ),
            ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('City').snapshots(),
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
              "Description": doc["Description"],
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
                  description: city["Description"]!,
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
    required String description,
    required String imageUrl,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Background Image
            Image.network(
              imageUrl,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            // Text Content
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => Karachi(name: name)),
                      // );
                    },
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
// floatingActionButton: FloatingActionButton(
//   onPressed: () {
//     Navigator.push(
//         context, MaterialPageRoute(builder: (builder) => Pets()));
//   },
//   backgroundColor: Color(0xFF1E88E5), // Set button color to blue
//   child: Icon(
//     Icons.read_more,
//     color: Colors.white, // Set icon color to white
//   ),
// ),
