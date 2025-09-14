import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_eproject/Veterinarian/AppointmentsCalendar.dart';
import 'package:flutter_eproject/Veterinarian/MedicalRecordsManagement.dart';
import 'package:flutter_eproject/login.dart';

class Veterinariandashboard extends StatefulWidget {
  @override
  _VeterinariandashboardState createState() => _VeterinariandashboardState();
}

class _VeterinariandashboardState extends State<Veterinariandashboard> {
  int _selectedIndex = 0;
  User? currentUser = FirebaseAuth.instance.currentUser;

  final List<Widget> _pages = [
    _buildWelcomeCard(),
    MedicalRecordsPage(),
    AppointmentsCalendarPage(),
  ];

  final List<String> _titles = [
    "Dashboard",
    "Medical Records",
    "Appointments",
  ];

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 6,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => login()),
              );
            },
          ),
        ],
      ),

      drawer: isWide ? null : _buildDrawer(),

      body: Row(
        children: [
          if (isWide) _buildSidebar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Widgets ----------------

  static Widget _buildWelcomeCard() {
    return Center(
      child: Card(
        elevation: 8,
        shadowColor: Colors.blue.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.medical_services, size: 60, color: Colors.white),
              SizedBox(height: 15),
              Text(
                "👨‍⚕️ Welcome to Veterinarian Dashboard",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.blue.shade700,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.medical_services, color: Colors.blue.shade700, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text("Veterinarian",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard, "Dashboard", 0),
            _buildDrawerItem(Icons.folder_copy, "Medical Records", 1),
            _buildDrawerItem(Icons.calendar_month, "Appointments", 2),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return NavigationRail(
      backgroundColor: Colors.white,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(Icons.medical_services, color: Colors.blue.shade700, size: 30),
            ),
            SizedBox(height: 8),
            Text("Doctor",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      destinations: [
        _railItem(Icons.dashboard, "Dashboard"),
        _railItem(Icons.folder_copy, "Records"),
        _railItem(Icons.calendar_month, "Appointments"),
      ],
    );
  }

  NavigationRailDestination _railItem(IconData icon, String label) {
    return NavigationRailDestination(
      icon: Icon(icon, color: Colors.white),
      selectedIcon: Icon(icon, color: Colors.yellowAccent),
      label: Text(label, style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      selectedTileColor: Colors.blue.shade400,
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }
}
