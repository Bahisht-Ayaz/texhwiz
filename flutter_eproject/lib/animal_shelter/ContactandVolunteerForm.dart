import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactVolunteerPage extends StatefulWidget {
  const ContactVolunteerPage({Key? key}) : super(key: key);

  @override
  State<ContactVolunteerPage> createState() => _ContactVolunteerPageState();
}

class _ContactVolunteerPageState extends State<ContactVolunteerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController msgCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController donationDetailsCtrl = TextEditingController();

  String? availability;
  String? donationType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _submitForm(String type) async {
    if (_formKey.currentState!.validate()) {
      try {
        if (type == "Contact") {
          await FirebaseFirestore.instance.collection("contacts").add({
            "name": nameCtrl.text,
            "email": emailCtrl.text,
            "message": msgCtrl.text,
            "createdAt": Timestamp.now(),
          });
        } else if (type == "Volunteer") {
          await FirebaseFirestore.instance.collection("volunteers").add({
            "name": nameCtrl.text,
            "email": emailCtrl.text,
            "phone": phoneCtrl.text,
            "availability": availability,
            "createdAt": Timestamp.now(),
          });
        } else if (type == "Donation") {
          await FirebaseFirestore.instance.collection("donations").add({
            "name": nameCtrl.text,
            "email": emailCtrl.text,
            "type": donationType,
            "details": donationDetailsCtrl.text,
            "createdAt": Timestamp.now(),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$type form submitted successfully ✅")),
        );

        // Clear fields after submit
        nameCtrl.clear();
        emailCtrl.clear();
        msgCtrl.clear();
        phoneCtrl.clear();
        donationDetailsCtrl.clear();
        setState(() {
          availability = null;
          donationType = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving $type form: $e")),
        );
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool multiline = false}) {
    return TextFormField(
      controller: controller,
      validator: (value) => value == null || value.isEmpty ? "Required" : null,
      maxLines: multiline ? 4 : 1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blue),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _contactForm() {
    return Column(
      children: [
        _buildTextField("Your Name", nameCtrl),
        const SizedBox(height: 12),
        _buildTextField("Your Email", emailCtrl),
        const SizedBox(height: 12),
        _buildTextField("Message", msgCtrl, multiline: true),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          ),
          onPressed: () => _submitForm("Contact"),
          child: const Text("Submit"),
        ),
      ],
    );
  }

  Widget _volunteerForm() {
    return Column(
      children: [
        _buildTextField("Full Name", nameCtrl),
        const SizedBox(height: 12),
        _buildTextField("Email", emailCtrl),
        const SizedBox(height: 12),
        _buildTextField("Phone Number", phoneCtrl),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Availability",
            labelStyle: const TextStyle(color: Colors.blue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          value: availability,
          items: const [
            DropdownMenuItem(value: "weekdays", child: Text("Weekdays")),
            DropdownMenuItem(value: "weekends", child: Text("Weekends")),
            DropdownMenuItem(value: "flexible", child: Text("Flexible")),
          ],
          onChanged: (val) => setState(() => availability = val),
          validator: (value) => value == null ? "Required" : null,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          ),
          onPressed: () => _submitForm("Volunteer"),
          child: const Text("Submit"),
        ),
      ],
    );
  }

  Widget _donationForm() {
    return Column(
      children: [
        _buildTextField("Full Name", nameCtrl),
        const SizedBox(height: 12),
        _buildTextField("Email", emailCtrl),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Donation Type",
            labelStyle: const TextStyle(color: Colors.blue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          value: donationType,
          items: const [
            DropdownMenuItem(value: "money", child: Text("Monetary")),
            DropdownMenuItem(value: "supplies", child: Text("Supplies")),
            DropdownMenuItem(value: "other", child: Text("Other")),
          ],
          onChanged: (val) => setState(() => donationType = val),
          validator: (value) => value == null ? "Required" : null,
        ),
        const SizedBox(height: 12),
        _buildTextField("Additional Details (optional)", donationDetailsCtrl,
            multiline: true),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          ),
          onPressed: () => _submitForm("Donation"),
          child: const Text("Submit"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Soft background
      appBar: AppBar(
        title: const Text("Contact & Volunteer"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Contact"),
            Tab(text: "Volunteer"),
            Tab(text: "Donation"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              _contactForm(),
              _volunteerForm(),
              _donationForm(),
            ],
          ),
        ),
      ),
    );
  }
}
