import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetHealthPage extends StatefulWidget {
  final String petId;
  const PetHealthPage({super.key, required this.petId});

  @override
  State<PetHealthPage> createState() => _PetHealthPageState();
}

class _PetHealthPageState extends State<PetHealthPage> {
  final _typeC = TextEditingController();
  final _descC = TextEditingController();
  final _notesC = TextEditingController();
  DateTime? _date;
  DateTime? _nextDue;

  Future<void> _addRecord() async {
    if (_typeC.text.isEmpty || _descC.text.isEmpty || _date == null) return;

    await FirebaseFirestore.instance
        .collection("pets_health")
        .doc(widget.petId)
        .collection("healthRecords")
        .add({
      "type": _typeC.text,
      "description": _descC.text,
      "notes": _notesC.text,
      "date": _date,
      "nextDueDate": _nextDue,
      "createdAt": FieldValue.serverTimestamp(),
    });

    _typeC.clear();
    _descC.clear();
    _notesC.clear();
    setState(() {
      _date = null;
      _nextDue = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("🐾 Pet Health Records"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("pets_health")
                  .doc(widget.petId)
                  .collection("healthRecords")
                  .orderBy("date", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Colors.blue));
                }
                final records = snapshot.data!.docs;
                if (records.isEmpty) {
                  return const Center(
                    child: Text(
                      "No health records yet 🐶",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.medical_services, color: Colors.blue),
                        ),
                        title: Text(
                          "${record["type"]}: ${record["description"]}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        subtitle: Text(
                          "📅 Date: ${record["date"].toDate().toString().split(' ')[0]}\n"
                          "⏰ Next Due: ${record["nextDueDate"] != null ? record["nextDueDate"].toDate().toString().split(' ')[0] : "N/A"}\n"
                          "📝 Notes: ${record["notes"] ?? ""}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add),
              label: const Text("Add Health Record", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("➕ Add Health Record", style: TextStyle(color: Colors.blue)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _typeC,
                decoration: const InputDecoration(
                  labelText: "Type (Vaccination/Deworming/Allergy)",
                  prefixIcon: Icon(Icons.category, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descC,
                decoration: const InputDecoration(
                  labelText: "Description",
                  prefixIcon: Icon(Icons.description, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesC,
                decoration: const InputDecoration(
                  labelText: "Notes",
                  prefixIcon: Icon(Icons.note_alt, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100),
                child: Text(_date == null ? "📅 Select Date" : "Date: ${_date!.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(color: Colors.blue)),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _nextDue = picked);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100),
                child: Text(
                  _nextDue == null ? "⏰ Select Next Due Date" : "Next Due: ${_nextDue!.toLocal().toString().split(' ')[0]}",
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _addRecord();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
