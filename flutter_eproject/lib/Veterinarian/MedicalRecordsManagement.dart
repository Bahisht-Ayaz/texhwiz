import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecordsPage extends StatefulWidget {
  @override
  _MedicalRecordsPageState createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  final TextEditingController petIdController = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();
  final TextEditingController prescriptionController = TextEditingController();

  bool _isLoading = false;

  // 📌 Upload to Firebase (Create)
  Future<void> uploadMedicalRecord() async {
    if (petIdController.text.isEmpty ||
        diagnosisController.text.isEmpty ||
        treatmentController.text.isEmpty ||
        prescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Please fill all fields")),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      await FirebaseFirestore.instance.collection("medical_records").add({
        "petId": petIdController.text.trim(),
        "diagnosis": diagnosisController.text.trim(),
        "treatment": treatmentController.text.trim(),
        "prescription": prescriptionController.text.trim(),
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Record added successfully")),
      );

      // clear fields
      petIdController.clear();
      diagnosisController.clear();
      treatmentController.clear();
      prescriptionController.clear();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  // 📌 Fetch and Show Medical History (Read)
  Stream<QuerySnapshot> getMedicalHistory() {
    return FirebaseFirestore.instance
        .collection("medical_records")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // 📌 Delete Record
  Future<void> deleteRecord(String docId) async {
    await FirebaseFirestore.instance.collection("medical_records").doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🗑 Record deleted")),
    );
  }

  // 📌 Update Record
  void showUpdateDialog(String docId, Map<String, dynamic> data) {
    final TextEditingController petId = TextEditingController(text: data['petId']);
    final TextEditingController diagnosis = TextEditingController(text: data['diagnosis']);
    final TextEditingController treatment = TextEditingController(text: data['treatment']);
    final TextEditingController prescription = TextEditingController(text: data['prescription']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("✏ Edit Record"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: petId, decoration: InputDecoration(labelText: "Pet ID")),
                TextField(controller: diagnosis, decoration: InputDecoration(labelText: "Diagnosis")),
                TextField(controller: treatment, decoration: InputDecoration(labelText: "Treatment")),
                TextField(controller: prescription, decoration: InputDecoration(labelText: "Prescription")),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Update"),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("medical_records")
                    .doc(docId)
                    .update({
                  "petId": petId.text.trim(),
                  "diagnosis": diagnosis.text.trim(),
                  "treatment": treatment.text.trim(),
                  "prescription": prescription.text.trim(),
                  "timestamp": FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("✅ Record updated")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🐾 Medical Records"),
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
                    Text("➕ Add Medical Record",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    TextField(
                      controller: petIdController,
                      decoration: InputDecoration(labelText: "Pet ID", border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: diagnosisController,
                      decoration: InputDecoration(labelText: "Diagnosis", border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: treatmentController,
                      decoration: InputDecoration(labelText: "Treatment Notes", border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: prescriptionController,
                      decoration: InputDecoration(labelText: "Prescription", border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                            onPressed: uploadMedicalRecord,
                            child: Text("Save Record"),
                          )
                  ],
                ),
              ),
            ),

            Divider(height: 30),

            // 📌 Records List (Read + Update + Delete)
            StreamBuilder<QuerySnapshot>(
              stream: getMedicalHistory(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("❌ Error fetching records"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final records = snapshot.data!.docs;

                if (records.isEmpty) {
                  return Center(child: Text("📭 No medical records yet"));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    var data = records[index].data() as Map<String, dynamic>;
                    String docId = records[index].id;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(Icons.medical_services, color: Colors.blue, size: 40),
                        title: Text(
                          "Pet ID: ${data['petId']} - ${data['diagnosis']}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Treatment: ${data['treatment']}\nPrescription: ${data['prescription']}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => showUpdateDialog(docId, data),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteRecord(docId),
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
