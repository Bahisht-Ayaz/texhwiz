import 'package:flutter/material.dart';
import 'package:flutter_eproject/animal_shelter/ManagePetListings.dart';
import 'package:flutter_eproject/animal_shelter/SuccessStories.dart';
import 'package:flutter_eproject/animal_shelter/ContactandVolunteerForm.dart';
import 'package:flutter_eproject/animal_shelter/ManageAdoptionRequest.dart';
import 'package:flutter_eproject/rateus.dart';

class ShelterDashboard extends StatefulWidget {
  @override
  _ShelterDashboardState createState() => _ShelterDashboardState();
}

class _ShelterDashboardState extends State<ShelterDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(
        child: Text("🏠 Welcome to Animal Shelter Dashboard",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    ManagePetListings(),
    SuccessStories(),
    ContactVolunteerPage(),
    ManageAdoptionRequests(),
    Rateus(),
  ];

  final List<String> _titles = [
    "Dashboard",
    "Manage Pet Listings",
    "Success Stories",
    "Contact & Volunteer Forms",
    "Manage Adoption Requests",
    "Rate Us",
  ];

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > 800; // ✅ Responsive check

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // ✅ Drawer for mobile
      drawer: isWide
          ? null
          : Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Color(0xFF1E88E5)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.pets,
                              color: Colors.blue, size: 30),
                        ),
                        SizedBox(height: 8),
                        Text("Shelter",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  _buildDrawerItem(Icons.dashboard, "Dashboard", 0),
                  _buildDrawerItem(Icons.pets, "Pet Listings", 1),
                  _buildDrawerItem(Icons.star, "Stories", 2),
                  _buildDrawerItem(Icons.volunteer_activism,
                      "Contact/Volunteer", 3),
                  _buildDrawerItem(Icons.list_alt, "Adoptions", 4),
                  _buildDrawerItem(Icons.rate_review, "Rate Us", 5),
                ],
              ),
            ),

      body: Row(
        children: [
          // ✅ Sidebar (NavigationRail) for big screens
          if (isWide)
            NavigationRail(
              backgroundColor: Color(0xFF1E88E5),
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
                      child: Icon(Icons.pets, color: Colors.blue, size: 30),
                    ),
                    SizedBox(height: 8),
                    Text("Shelter",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard, color: Colors.white),
                  selectedIcon: Icon(Icons.dashboard, color: Colors.yellow),
                  label:
                      Text("Dashboard", style: TextStyle(color: Colors.white)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.pets, color: Colors.white),
                  selectedIcon: Icon(Icons.pets, color: Colors.yellow),
                  label:
                      Text("Pet Listings", style: TextStyle(color: Colors.white)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.star, color: Colors.white),
                  selectedIcon: Icon(Icons.star, color: Colors.yellow),
                  label: Text("Stories", style: TextStyle(color: Colors.white)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.volunteer_activism, color: Colors.white),
                  selectedIcon:
                      Icon(Icons.volunteer_activism, color: Colors.yellow),
                  label:
                      Text("Contact/Volunteer", style: TextStyle(color: Colors.white)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.list_alt, color: Colors.white),
                  selectedIcon: Icon(Icons.list_alt, color: Colors.yellow),
                  label:
                      Text("Adoptions", style: TextStyle(color: Colors.white)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.rate_review, color: Colors.white),
                  selectedIcon:
                      Icon(Icons.rate_review, color: Colors.yellow),
                  label: Text("Rate Us", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),

          // ✅ Main Content
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context); // Close drawer after selection
      },
    );
  }
}
