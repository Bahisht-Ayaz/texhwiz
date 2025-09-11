import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Pets());
}

class Pets extends StatelessWidget {
  const Pets({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Add Pets',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Add Pets Form'),
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController photoController = TextEditingController();

  void saveData() async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      await db.collection("Pets").add({
        "Name": nameController.text,
        "Age": ageController.number,
        "Breed": breedController.text,
        "Gender": genderController.text,
        "Photo": photoController.text,

      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data added successfully!")),
      );

      nameController.clear();
      ageController.clear();
      breedController.clear();
      genderController.clear();
      photoController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (builder) => Dash()),
        //     );
        //   },
        // ),
        // backgroundColor: Color(0xFF1E88E5), // Sky green background color
        // elevation: 4, // Adds a subtle shadow
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Add Pets",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              buildTextField(
                controller: nameController,
                hintText: "Enter Pet Name",
                labelText: "Pet Name",
                icon: Icons.location_city,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: ageController,
                hintText: "Enter Age",
                labelText: "Age",
                icon: Icons.number,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: breedController,
                hintText: "Enter Breed",
                labelText: "Breed",
                icon: Icons.abc,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: genderController,
                hintText: "Enter Gender",
                labelText: "Breed",
                icon: Icons.gender,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: photoController,
                hintText: "Enter Image",
                labelText: "Image",
                icon: Icons.image,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: const Color(0xFF1E88E5),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
     floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
        context, MaterialPageRoute(builder: (builder) => pshow()));
  },
  backgroundColor: Color(0xFF1E88E5), // Set button color to blue
  child: Icon(
    Icons.read_more,
    color: Colors.white, // Set icon color to white
  ),
),

    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        hintText: hintText,
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
