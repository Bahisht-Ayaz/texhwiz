import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_eproject/city.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Feedbacks());
}

class Feedbacks extends StatelessWidget {
  const Feedbacks({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Feedback Form',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Feedback Form'),
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
  final TextEditingController message = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void saveData() {
    if (_formKey.currentState!.validate()) {
      try {
        FirebaseFirestore db = FirebaseFirestore.instance;
        db.collection("Feedback").add({
          "Name": name.text.trim(),
          "Email": email.text.trim(),
          "Message": message.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved Data Successfully")),
        );
        name.clear();
        email.clear();
        message.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$e")),
        );
      }
    }
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Message is required";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Back arrow icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (builder) => City()),
            ); // Navigate to the previous page
          },
        ),
        backgroundColor: Color(0xFF1E88E5), // Sky green background color
        elevation: 4, // Adds a subtle shadow
        centerTitle: true, // Title aligned to the left
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Feedback Form",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  buildTextField(
                    controller: name,
                    hintText: "Enter Name",
                    icon: Icons.person,
                    obscureText: false,
                    validator: validateName,
                  ),
                  const SizedBox(height: 20),
                  buildTextField(
                    controller: email,
                    hintText: "Enter Email",
                    icon: Icons.mail,
                    obscureText: false,
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 20),
                  buildTextField(
                    controller: message,
                    hintText: "Enter Message",
                    icon: Icons.message,
                    obscureText: false,
                    validator: validateMessage,
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton.icon(
                    onPressed: saveData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                    ),
                    label: const Text(
                      "Submit Feedback",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.lightBlue),
                    ),
                    icon: const Icon(Icons.feedback_sharp,color: Colors.lightBlue,),
                  ),
                  const SizedBox(height: 20),
                  
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
    required String? Function(String?) validator,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black),
          ),
          hintText: hintText,
          suffixIcon: Icon(icon, color: Colors.black),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}