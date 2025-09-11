import 'package:flutter/material.dart';
import 'package:flutter_eproject/city.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void main() {
  runApp(Rateus());
}

class Rateus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rate Us Page',
      
      home: RateUsPage(),
    );
  }
}

class RateUsPage extends StatefulWidget {
  @override
  _RateUsPageState createState() => _RateUsPageState();
}

class _RateUsPageState extends State<RateUsPage> {
  double _rating = 0;
  bool _isRated = false; // To track whether the user has rated

  // Navigate to the next page after rating submission
  void _submitRating() {
    if (_rating > 0) {
      setState(() {
        _isRated = true; // Mark the app as rated
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ThankYouPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please rate the app before submitting.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
    
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 12,
              shadowColor: Colors.black.withOpacity(0.3), // Subtle shadow for card
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon or logo at the top (Optional)
                    Icon(
                      Icons.star_rate,
                      size: 100,
                      color: Colors.amber, // Golden icon
                    ),
                    SizedBox(height: 20),

                    // Attractive Rate Us Heading
                    if (!_isRated) // Only show the title if not rated
                      Text(
                        'We Value Your Feedback!',
                        style: TextStyle(
                          fontSize: 32, // Larger font size
                          fontWeight: FontWeight.bold, // Make it bold
                          color: Colors.black, // Vibrant amber color
                          letterSpacing: 2.0, // Slightly increased letter spacing
                          shadows: [
                            Shadow(
                              blurRadius: 5.0,
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(3.0, 3.0),
                            ),
                          ], // Text shadow for extra pop
                        ),
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(height: 10),

                    // Description Text
                    if (!_isRated) // Only show the description if not rated
                      Text(
                        'Please rate our app and help us improve your experience.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(height: 30),

                    // Star Rating Widget
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemSize: 40,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber, // Golden stars
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                    SizedBox(height: 30),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitRating,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1E88E5), // Golden color for the button
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 8, // Slight shadow for the button
                      ),
                      child: Text(
                        'Submit Rating',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Black text color for the button
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Maybe Later Button
                    if (!_isRated) // Only show the "Maybe Later" button if not rated
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (builder)=>City())); // Close the Rate Us screen
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          side: BorderSide(color: Color(0xFF1E88E5), width: 1.5), // Golden border for maybe later
                        ),
                        child: Text(
                          'Maybe Later',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black, // Golden text color for maybe later
                            fontWeight: FontWeight.bold,
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

class ThankYouPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1E88E5),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.thumb_up,
                size: 100,
                color: const Color.fromARGB(255, 113, 255, 118), // Green thumbs-up icon for success
              ),
              SizedBox(height: 20),
              Text(
                'Thank You for Your Feedback!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Your feedback helps us improve our app.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (builder)=>City())); // Close the Rate Us screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E88E5), // Green color for the button
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 8, // Slight shadow for the button
                ),
                child: Text(
                  'Ok',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}