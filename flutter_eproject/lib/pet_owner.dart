import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_eproject/Veterinarian/veterinariandashboard.dart';
import 'package:flutter_eproject/animal_shelter/shelter.dart';

// Import your pages
// import 'petownwer/petprofile.dart';  // ❌ My Pets ka page hata diya
import 'petownwer/HealthTracking.dart';
import 'petownwer/appoinments.dart';
import 'petownwer/petstore.dart';
import 'petownwer/blogstips.dart';
import 'rateus.dart';
import 'feedback.dart';
import 'Contactus.dart';
import 'login.dart';  // 👈 ensure login.dart is imported

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  int _currentIndex = 0;

  final List<String> bannerImages = [
    "https://images.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg?cs=srgb&dl=pexels-pixabay-104827.jpg&fm=jpg",
    "https://static.vecteezy.com/system/resources/thumbnails/005/857/332/small_2x/funny-portrait-of-cute-corgi-dog-outdoors-free-photo.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpYHVB1Y0hDW9xml-yN68cjeZuN3BX_0Y2Kg&s",
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildHomePage(context),
      _buildSettingsPage(context),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  // 🔹 Home Page Content
  Widget _buildHomePage(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(
            elevation: 0,
            backgroundColor: Colors.blue,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: currentUser?.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : null,
                  child: currentUser?.photoURL == null
                      ? const Icon(Icons.person, color: Colors.blue)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  "Hi, ${currentUser?.displayName ?? "Pet Lover"} 👋",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ],
            ),
          ),

          // 🔹 Banner Carousel
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: bannerImages.map((imgUrl) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(imgUrl, fit: BoxFit.cover, width: 1000),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 Features Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Explore Features 🐾",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900]),
            ),
          ),

          const SizedBox(height: 12),

          // 🔹 Features Grid
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildFeatureCard(context, Icons.monitor_heart,
                    "Health Tracking", "Track pet health", PetHealthPage(petId: "abc123"), Colors.red),
                _buildFeatureCard(context, Icons.calendar_month, "Appointments",
                    "Book vet visits", const AppointmentPage(), Colors.blue),
                _buildFeatureCard(context, Icons.shopping_bag, "Pet Store",
                    "Shop for pets", const PetStorePage(), Colors.green),
                _buildFeatureCard(context, Icons.article, "Blogs & Tips",
                    "Learn pet care", const BlogTipsPage(), Colors.purple),
                _buildFeatureCard(context, Icons.feedback, "Feedback",
                    "Share your views", const Feedbacks(), Colors.teal),
                _buildFeatureCard(context, Icons.star_rate, "Rate Us",
                    "Give rating", Rateus(), Colors.amber),
                _buildFeatureCard(context, Icons.support_agent, "Contact Us",
                    "We are here to help", Contactus(), Colors.indigo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Settings Page (Logout Option)
  Widget _buildSettingsPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => login()),
            );
          },
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text("Logout", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // 🔹 Reusable Feature Card
  Widget _buildFeatureCard(BuildContext context, IconData icon, String title,
      String subtitle, Widget page, Color bgColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [bgColor.withOpacity(0.9), bgColor.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 28,
                child: Icon(icon, size: 30, color: bgColor),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
