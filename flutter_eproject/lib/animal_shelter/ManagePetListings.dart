import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagePetListings extends StatefulWidget {
  @override
  _ManagePetListingsState createState() => _ManagePetListingsState();
}

class _ManagePetListingsState extends State<ManagePetListings> {
  final _formKey = GlobalKey<FormState>();
  String _type = '';
  String _age = '';
  String _gender = 'Male';
  String _healthStatus = '';
  String _adoptionStatus = 'Available';

  Future<void> _addPet() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // ✅ Save pet details to Firestore (no image)
        await FirebaseFirestore.instance.collection("petslistning").add({
          'type': _type,
          'age': _age,
          'gender': _gender,
          'health': _healthStatus,
          'status': _adoptionStatus,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pet added successfully!")),
        );

        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    setState(() {
      _gender = 'Male';
      _adoptionStatus = 'Available';
    });
  }

  Future<void> _removePet(String docId) async {
    try {
      // ✅ Delete from Firestore
      await FirebaseFirestore.instance.collection("petslistning").doc(docId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting pet: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Pet Listings')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Animal Type'),
                    onSaved: (value) => _type = value!,
                    validator: (value) => value!.isEmpty ? 'Enter type' : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Age'),
                    onSaved: (value) => _age = value!,
                    validator: (value) => value!.isEmpty ? 'Enter age' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    items: ['Male', 'Female'].map((gender) {
                      return DropdownMenuItem(value: gender, child: Text(gender));
                    }).toList(),
                    onChanged: (value) => setState(() => _gender = value!),
                    decoration: InputDecoration(labelText: 'Gender'),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Health Status'),
                    onSaved: (value) => _healthStatus = value!,
                    validator: (value) => value!.isEmpty ? 'Enter health status' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _adoptionStatus,
                    items: ['Available', 'Adopted', 'Pending'].map((status) {
                      return DropdownMenuItem(value: status, child: Text(status));
                    }).toList(),
                    onChanged: (value) => setState(() => _adoptionStatus = value!),
                    decoration: InputDecoration(labelText: 'Adoption Status'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addPet,
                    child: Text('Add Pet'),
                  ),
                  Divider(height: 30),
                ],
              ),
            ),

            // ✅ Firestore Data Fetch & Display
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("petslistning")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final pets = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.pets, size: 40, color: Colors.red),
                        title: Text('${pet['type']} (${pet['gender']}, ${pet['age']} yrs)'),
                        subtitle: Text('Health: ${pet['health']}\nStatus: ${pet['status']}'),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removePet(pet.id),
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
