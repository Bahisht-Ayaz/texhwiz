import 'package:admin_dashboard/dash.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 👈 for formatting DateTime

class AppointmentDetailsScreen extends StatefulWidget {
  @override
  _AppointmentDetailsScreenState createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to format Firestore Timestamp
  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "N/A";
    DateTime date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy hh:mm a').format(date); // Example: 15/09/2025 05:30 PM
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Appointments",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (builder) => Dash()),
            );
          },
        ),
        backgroundColor: const Color(0xFF1E88E5),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('appointments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No appointments found",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            );
          }

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final data = appointment.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pet ID: ${data['petId'] ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Vet ID: ${data['vetId'] ?? 'N/A'}",
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Date/Time: ${formatTimestamp(data['dateTime'])}",
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Reason: ${data['reason'] ?? 'N/A'}",
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Status: ${data['status'] ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Created At: ${formatTimestamp(data['createdAt'])}",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
