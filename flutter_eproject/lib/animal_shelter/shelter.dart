import 'package:flutter/material.dart';
import 'package:flutter_eproject/animal_shelter/ManagePetListings.dart';
import 'package:flutter_eproject/animal_shelter/SuccessStories.dart';
import 'package:flutter_eproject/animal_shelter/ContactandVolunteerForm.dart';
import 'package:flutter_eproject/animal_shelter/ManageAdoptionRequest.dart';
import 'package:flutter_eproject/login.dart';
import 'package:flutter_eproject/pet_owner.dart';
import 'package:flutter_eproject/rateus.dart';

class ShelterDashboard extends StatefulWidget {
  @override
  _ShelterDashboardState createState() => _ShelterDashboardState();
}

class _ShelterDashboardState extends State<ShelterDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    _buildWelcomeCard(),
    ManagePetListings(),
    SuccessStories(),
    ContactVolunteerPage(),
    ManageAdoptionRequests(),
    // Rateus(),
  ];

  final List<String> _titles = [
    "Dashboard",
    "Manage Pet Listings",
    "Success Stories",
    "Contact & Volunteer Forms",
    "Manage Adoption Requests",
    // "Rate Us",
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
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                onPressed: () {
                  Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
                },
                icon: Icon(Icons.pets, color: Colors.blue,))),
          ),
        ],
      ),

      // Drawer for Mobile
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
              Icon(Icons.pets, size: 60, color: Colors.white),
              SizedBox(height: 15),
              Text(
                "🏠 Welcome to Animal Shelter Dashboard",
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
                        Icon(Icons.pets, color: Colors.blue.shade700, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text("Animal Shelter",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard, "Dashboard", 0),
            _buildDrawerItem(Icons.pets, "Pet Listings", 1),
            _buildDrawerItem(Icons.star, "Stories", 2),
            _buildDrawerItem(Icons.volunteer_activism, "Contact/Volunteer", 3),
            _buildDrawerItem(Icons.list_alt, "Adoptions", 4),
            // _buildDrawerItem(Icons.rate_review, "Rate Us", 5),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return NavigationRail(
      backgroundColor: Colors.blue.shade700,
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
              child: Icon(Icons.pets, color: Colors.blue.shade700, size: 30),
            ),
            SizedBox(height: 8),
            Text("Shelter",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      destinations: [
        _railItem(Icons.dashboard, "Dashboard"),
        _railItem(Icons.pets, "Pet Listings"),
        _railItem(Icons.star, "Stories"),
        _railItem(Icons.volunteer_activism, "Contact"),
        _railItem(Icons.list_alt, "Adoptions"),
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
        Navigator.pop(context); // Close drawer
      },
    );
  }
}
