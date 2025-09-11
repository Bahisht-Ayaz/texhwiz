import 'package:flutter/material.dart';
import 'package:flutter_eproject/city.dart';


void main() => runApp(Contact());

class Contact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
   
      theme: ThemeData(
        primarySwatch: Colors.yellow, // Yellow as the primary color
        scaffoldBackgroundColor: Colors.white, // White background
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
        textTheme: TextTheme(
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      home: ContactUsForm(), // Set ContactUsForm as the home page
    );
  }
}

class ContactUsForm extends StatefulWidget {
  @override
  _ContactUsFormState createState() => _ContactUsFormState();
}

class _ContactUsFormState extends State<ContactUsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      print('Name: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      print('Message: ${_messageController.text}');

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Message sent successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (builder) => City()),
            );
          },
        ),
        backgroundColor: Color(0xFF1E88E5),
        elevation: 4,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth < 600 ? screenWidth * 0.9 : 600,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Contact Us', // The heading
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.black,
                              fontSize: 40
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 10), // Space below the heading

                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'We would love to hear from you!', // Subtitle (optional)
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Adjust space before the form

                    // Name Text Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    // Email Text Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Your Email',
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    // Message Text Field
                    TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Your Message',
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your message';
                        }
                        return null;
                      },
                    ),
SizedBox(height: 20),

// Submit Button
Center( // Button ko center align karne ke liye Center widget
  child: SizedBox(
    width: MediaQuery.of(context).size.width * 0.5, // Screen width ka 50%
    child: ElevatedButton(
      onPressed: _submitForm,
      child: Text(
        'SUBMIT',
        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Color(0xFF1E88E5)),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(vertical: 16.0),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
      ),
    );
  }
}
