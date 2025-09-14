import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentsCalendarPage extends StatefulWidget {
  @override
  _AppointmentsCalendarPageState createState() => _AppointmentsCalendarPageState();
}

class _AppointmentsCalendarPageState extends State<AppointmentsCalendarPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  // 📌 Add appointment slot
  Future<void> _addAppointment() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Please select date & time")),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final DateTime slotDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection("appointments").add({
        "dateTime": slotDateTime,
        "status": "Available",
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Appointment slot added")),
      );

      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  // 📌 Delete appointment slot
  Future<void> _removeAppointment(String docId) async {
    try {
      await FirebaseFirestore.instance.collection("appointments").doc(docId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error deleting appointment: $e")),
      );
    }
  }

  // 📌 Confirm appointment
  Future<void> _confirmAppointment(String docId) async {
    try {
      await FirebaseFirestore.instance.collection("appointments").doc(docId).update({
        "status": "Confirmed",
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Appointment confirmed")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  // 📌 Reschedule appointment
  Future<void> _rescheduleAppointment(String docId, DateTime oldDateTime) async {
    DateTime? newDate;
    TimeOfDay? newTime;

    // Pick new date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: oldDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) newDate = pickedDate;

    // Pick new time
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(oldDateTime),
    );
    if (pickedTime != null) newTime = pickedTime;

    if (newDate == null || newTime == null) return;

    DateTime newDateTime = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      newTime.hour,
      newTime.minute,
    );

    try {
      await FirebaseFirestore.instance.collection("appointments").doc(docId).update({
        "dateTime": newDateTime,
        "status": "Rescheduled",
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Appointment rescheduled")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  // 📌 Fetch Appointments
  Stream<QuerySnapshot> _getAppointments() {
    return FirebaseFirestore.instance
        .collection("appointments")
        .orderBy("dateTime", descending: false)
        .snapshots();
  }

  // 📌 Pick Date
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // 📌 Pick Time
  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📅 Appointments Calendar"),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 📌 Form Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "➕ Add Availability Slot",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _pickDate,
                            child: Text(
                              _selectedDate == null
                                  ? "Select Date"
                                  : DateFormat.yMMMd().format(_selectedDate!),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _pickTime,
                            child: Text(
                              _selectedTime == null
                                  ? "Select Time"
                                  : _selectedTime!.format(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                            onPressed: _addAppointment,
                            child: Text("Save Slot"),
                          ),
                  ],
                ),
              ),
            ),

            Divider(height: 30),

            // 📌 Appointments List
            StreamBuilder<QuerySnapshot>(
              stream: _getAppointments(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text("❌ Error fetching appointments");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final slots = snapshot.data!.docs;
                if (slots.isEmpty) return Text("📭 No appointments yet");

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final dateTime = (slot['dateTime'] as Timestamp).toDate();

                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.schedule, size: 40, color: Colors.teal),
                        title: Text(DateFormat.yMMMd().add_jm().format(dateTime)),
                        subtitle: Text("Status: ${slot['status']}"),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check_circle, color: Colors.green),
                              tooltip: "Confirm",
                              onPressed: () => _confirmAppointment(slot.id),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              tooltip: "Reschedule",
                              onPressed: () => _rescheduleAppointment(slot.id, dateTime),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              tooltip: "Delete",
                              onPressed: () => _removeAppointment(slot.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
