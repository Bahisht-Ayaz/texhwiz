import 'package:admin_dashboard/AdminPetStoreForm.dart';
import 'package:admin_dashboard/appointments.dart';
import 'package:admin_dashboard/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Dash extends StatefulWidget {
  const Dash({super.key});

 

  @override
  State<Dash> createState() => _DashState();
}

class _DashState extends State<Dash> {
  int totalUsers = 0;
  int totalAppointments = 0;


  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    // Fetch total users
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('User').get();
    // Fetch total cities
    QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance.collection('appointments').get();
    // Fetch total malls

    setState(() {
      totalUsers = usersSnapshot.docs.length;
      totalAppointments = appointmentsSnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1E88E5),
        title: Text("Admin Dashboard",style: TextStyle(color: Colors.white),),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Admin"),
              accountEmail: Text("admin@petscare.com"),
              currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage("https://static.vecteezy.com/system/resources/thumbnails/005/129/844/small/profile-user-icon-isolated-on-white-background-eps10-free-vector.jpg"),)
            ),
             ListTile(
              leading: Icon(Icons.person, color: Colors.black),
              title: Text("Users", style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (builder) => UserDetailsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.health_and_safety, color: Colors.black),
              title: Text("Appointments", style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (builder) => AppointmentDetailsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.store, color: Colors.black),
              title: Text("Pet store", style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (builder) => AdminPetStorePage()));
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.deepOrange),
                title: Text("Total Users"),
                trailing: Text("$totalUsers", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.health_and_safety, color: Colors.blue),
                title: Text("Total Appointments"),
                trailing: Text("$totalAppointments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
