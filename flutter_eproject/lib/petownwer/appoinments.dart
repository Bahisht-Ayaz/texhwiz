import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final _reasonC = TextEditingController();
  String? _selectedPet;
  String? _selectedVet;
  DateTime? _selectedDate;

  // ✅ Appointment Add
  Future<void> _bookAppointment() async {
    if (_selectedPet == null ||
        _selectedVet == null ||
        _selectedDate == null ||
        _reasonC.text.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection("appointments").add({
        "userId": FirebaseAuth.instance.currentUser!.uid,
        "petId": _selectedPet,
        "vetId": _selectedVet,
        "reason": _reasonC.text,
        "dateTime": Timestamp.fromDate(_selectedDate!),
        "status": "upcoming",
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Appointment booked")),
      );

      _reasonC.clear();
      setState(() {
        _selectedDate = null;
        _selectedPet = null;
        _selectedVet = null;
      });
      Navigator.pop(context);
    } catch (e) {
      print("❌ Error booking appointment: $e");
    }
  }

  // ✅ Show Add Appointment Dialog
  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text("Book Appointment",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedPet,
                items: ["Pet1", "Pet2"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedPet = val),
                decoration: const InputDecoration(
                  labelText: "Select Pet",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedVet,
                items: ["Dr. Ali (Vet)", "Happy Paws Groomer"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedVet = val),
                decoration: const InputDecoration(
                  labelText: "Select Vet/Groomer",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reasonC,
                decoration: const InputDecoration(
                  labelText: "Reason for Visit",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedDate = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_selectedDate == null
                    ? "Select Date & Time"
                    : "Selected: ${_selectedDate.toString().substring(0, 16)}"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _bookAppointment,
            child: const Text("Book"),
          ),
        ],
      ),
    );
  }

  // ✅ Update status (Cancel / Complete)
  Future<void> _updateStatus(String id, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection("appointments")
          .doc(id)
          .update({"status": status});
    } catch (e) {
      print("❌ Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.blue[50],
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("appointments")
              .where("userId", isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(
                  child: Text("No Appointments",
                      style:
                          TextStyle(fontSize: 18, color: Colors.blueGrey)));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final appt = docs[index];
                final data = appt.data() as Map<String, dynamic>;

                final date = data["dateTime"] is Timestamp
                    ? (data["dateTime"] as Timestamp).toDate()
                    : null;

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: const Icon(Icons.pets, color: Colors.white),
                    ),
                    title: Text(data["vetId"] ?? "Unknown",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent)),
                    subtitle: Text(
                      "🐾 Pet: ${data["petId"] ?? "N/A"}\n"
                      "📋 Reason: ${data["reason"] ?? "N/A"}\n"
                      "📅 Date: ${date != null ? date.toString().substring(0, 16) : "No Date"}\n"
                      "📌 Status: ${data["status"] ?? "N/A"}",
                      style: const TextStyle(height: 1.5),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == "Cancel") {
                          _updateStatus(appt.id, "cancelled");
                        }
                        if (val == "Complete") {
                          _updateStatus(appt.id, "completed");
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                            value: "Complete", child: Text("Mark Complete")),
                        PopupMenuItem(
                            value: "Cancel", child: Text("Cancel Appointment")),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: _showBookingDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
