import 'package:flutter/material.dart';

class AdoptionRequest {
  final String petName;
  final String userName;
  final String userContact;
  String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime requestDate;

  AdoptionRequest({
    required this.petName,
    required this.userName,
    required this.userContact,
    this.status = 'Pending',
    required this.requestDate,
  });
}

class ManageAdoptionRequests extends StatefulWidget {
  @override
  _ManageAdoptionRequestsState createState() => _ManageAdoptionRequestsState();
}

class _ManageAdoptionRequestsState extends State<ManageAdoptionRequests> {
  List<AdoptionRequest> _requests = [
    AdoptionRequest(
      petName: 'Max',
      userName: 'Ali Khan',
      userContact: 'ali@example.com',
      requestDate: DateTime.now().subtract(Duration(days: 1)),
    ),
    AdoptionRequest(
      petName: 'Bella',
      userName: 'Sara Malik',
      userContact: 'sara@example.com',
      status: 'Approved',
      requestDate: DateTime.now().subtract(Duration(days: 3)),
    ),
    AdoptionRequest(
      petName: 'Rocky',
      userName: 'Ahmed Raza',
      userContact: 'ahmed@example.com',
      status: 'Rejected',
      requestDate: DateTime.now().subtract(Duration(days: 2)),
    ),
  ];

  void _updateRequestStatus(int index, String newStatus) {
    setState(() {
      _requests[index].status = newStatus;

      // Optionally: Show feedback (e.g., SnackBar, notification, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request ${newStatus.toLowerCase()} for ${_requests[index].petName}.'),
        ),
      );
    });
  }

  Widget _buildStatusButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Adoption Requests'),
      ),
      body: ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🐾 Pet: ${request.petName}', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('👤 User: ${request.userName}'),
                  Text('📧 Contact: ${request.userContact}'),
                  Text('📅 Requested on: ${request.requestDate.toLocal().toString().split(' ')[0]}'),
                  Text('📌 Status: ${request.status}',
                      style: TextStyle(
                        color: request.status == 'Approved'
                            ? Colors.green
                            : request.status == 'Rejected'
                                ? Colors.red
                                : Colors.orange,
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(height: 8),
                  if (request.status == 'Pending')
                    Row(
                      children: [
                        _buildStatusButton(
                          'Approve',
                          Colors.green,
                          () => _updateRequestStatus(index, 'Approved'),
                        ),
                        SizedBox(width: 10),
                        _buildStatusButton(
                          'Reject',
                          Colors.red,
                          () => _updateRequestStatus(index, 'Rejected'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
