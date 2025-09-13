import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_eproject/pet_owner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Contactus());
}

class Contactus extends StatelessWidget {
  const Contactus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contact Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.blue.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const MyHomePage(title: 'Contact Form'),
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
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController message = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void saveData() {
    if (_formKey.currentState!.validate()) {
      try {
        FirebaseFirestore db = FirebaseFirestore.instance;
        db.collection("Contact").add({
          "Name": name.text.trim(),
          "Email": email.text.trim(),
          "Phoneno": phone.text.trim(),
          "Message": message.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Data Saved Successfully")),
        );
        name.clear();
        email.clear();
        phone.clear();
        message.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (builder) => HomePage()),
            );
          },
        ),
        title: const Text("Contact Us", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 12,
            shadowColor: Colors.blue.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Contact Us",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildTextField(
                      controller: name,
                      hintText: "Enter Name",
                      icon: Icons.person,
                      validator: (val) =>
                          val == null || val.isEmpty ? "Name required" : null,
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: email,
                      hintText: "Enter Email",
                      icon: Icons.mail,
                      validator: (val) =>
                          val == null || !val.contains("@") ? "Valid Email required" : null,
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: phone,
                      hintText: "Enter Phone Number",
                      icon: Icons.phone,
                      validator: (val) =>
                          val == null || val.length < 10 ? "Valid Phone required" : null,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: message,
                      hintText: "Enter Message",
                      icon: Icons.message,
                      validator: (val) =>
                          val == null || val.isEmpty ? "Message required" : null,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      onPressed: saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text(
                        "Submit",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
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
    required String? Function(String?) validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
      ),
    );
  }
}
