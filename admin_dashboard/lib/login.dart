import 'package:admin_dashboard/dash.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLoginForm extends StatefulWidget {
  @override
  _AdminLoginFormState createState() => _AdminLoginFormState();
}

class _AdminLoginFormState extends State<AdminLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      // Perform your login logic here
      if (email == "admin@petscare.com" && password == "admin123") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login successful!",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (a) => Dash()));
        // Navigate to admin dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid email or password.",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Login", style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(16.0),
          color: Color.fromARGB(255, 57, 166, 255),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Welcome, Admin!",
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 255, 255, 255)),
                  ),
                  SizedBox(height: 16.0),
TextFormField(
  controller: _emailController,
  decoration: InputDecoration(
    labelText: "Email",
    labelStyle: TextStyle(color: Colors.white),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    prefixIcon: Icon(Icons.email, color: Colors.white),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white), // Border color
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white), // Border color when focused
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  style: TextStyle(color: Colors.white), // Text color
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email";
    } else if (!RegExp(
            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")
        .hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  },
),
SizedBox(height: 16.0),
TextFormField(
  controller: _passwordController,
  decoration: InputDecoration(
    labelText: "Password",
    labelStyle: TextStyle(color: Colors.white),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    prefixIcon: Icon(Icons.lock, color: Colors.white),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white), // Border color
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white), // Border color when focused
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  style: TextStyle(color: Colors.white), // Text color
  obscureText: true,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    } else if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  },
),

                  SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: Text("Login",
                          style: GoogleFonts.poppins(fontSize: 16.0)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      textTheme: GoogleFonts.poppinsTextTheme(),
    ),
    home: AdminLoginForm(),
  ));
}
