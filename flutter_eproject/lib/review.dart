import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_eproject/city.dart';

void main() {
  runApp(const feedback());
}

class feedback extends StatelessWidget {
  const feedback({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
     
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  String? message;
  double rating = 3.0;

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
        backgroundColor: const Color.fromARGB(255, 218, 134, 38), // Sky green background color
        elevation: 4, // Adds a subtle shadow
        centerTitle: true, // Title aligned to the left
      ),
      body:
       Stack(
        children: [
          
       
       Center(
        
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                  'Feedback Form',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
        
                Text(
                  'We value your feedback!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                                        TextFormField(
  decoration: InputDecoration(
    labelText: 'Name',
    labelStyle: TextStyle(color: Colors.black), // Label text color
    border: OutlineInputBorder(), // Default border
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black,), // White border when not focused
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width: 2.0), // White border when focused
    ),
  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value,
                                 style: TextStyle(color: Colors.black), // Input text color
),
                SizedBox(height: 20),
                            TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    labelStyle: TextStyle(color: Colors.black), // Label text color
    border: OutlineInputBorder(), // Default border
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black), // White border when not focused
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width: 2.0), // White border when focused
    ),
  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) => email = value,
                   style: TextStyle(color: Colors.black), // Input text color
),
                
                SizedBox(height: 20),
            TextFormField(
  decoration: InputDecoration(
    labelText: 'Feedback',
    labelStyle: TextStyle(color: Colors.black), // Label text color
    border: OutlineInputBorder(), // Default border
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black), // White border when not focused
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width: 2.0), // White border when focused
    ),
  ),
  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your feedback';
                    }
                    return null;
                  },
                  onSaved: (value) => message = value,
  style: TextStyle(color: Colors.black), // Input text color
),

                SizedBox(height: 20),
                Text(
  'Rate your experience:',
  style: TextStyle(fontSize: 16,color: Colors.black),
),
Slider(
  value: rating,
  min: 1,
  max: 5,
  divisions: 4,
  label: rating.toString(),
  activeColor: const Color.fromARGB(255, 218, 134, 38), // Sets the active color to yellow
  inactiveColor: const Color.fromARGB(255, 26, 23, 19), // Optionally, sets the inactive color to a lighter shade of yellow
  onChanged: (value) {
    setState(() {
      rating = value;
    });
  },
),
                SizedBox(height: 20),
           Center(
  child: ElevatedButton(
    onPressed: () {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        _submitFeedback();
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.yellow, // Background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Optional: Rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Button padding
    ),
        child: Text(
                        'Submit Feedback',
                        style: TextStyle(
                          color: Colors.black,
                         
                        ),
                      ),
  ),
),

              ],
            ),
          ),
        ),
      ),
        ]
    )
    );

      
        
  }

  void _submitFeedback() {
    // Handle form submission logic here
    // For example, send feedback to a server or save it locally

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thank You!'),
        content: Text(
          'Your feedback has been submitted:\n\n'
          'Name: $name\nEmail: $email\nRating: $rating\nMessage: $message',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to the previous page
            },
            child: Text('OK'),
          ),
        ],
      ),
    
    );
  }
}
