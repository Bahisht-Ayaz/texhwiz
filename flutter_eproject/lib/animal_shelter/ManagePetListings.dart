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
        await FirebaseFirestore.instance.collection("petslistning").add({
          'type': _type,
          'age': _age,
          'gender': _gender,
          'health': _healthStatus,
          'status': _adoptionStatus,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Pet added successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
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
      await FirebaseFirestore.instance.collection("petslistning").doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pet deleted successfully!"),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting pet: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // light background
      appBar: AppBar(
        title: Text('🐾 Manage Pet Listings',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 📝 Form
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Add a New Pet",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Animal Type',
                          prefixIcon: Icon(Icons.pets, color: Colors.blue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSaved: (value) => _type = value!,
                        validator: (value) => value!.isEmpty ? 'Enter type' : null,
                      ),
                      SizedBox(height: 12),

                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Age',
                          prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSaved: (value) => _age = value!,
                        validator: (value) => value!.isEmpty ? 'Enter age' : null,
                      ),
                      SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _gender,
                        items: ['Male', 'Female'].map((gender) {
                          return DropdownMenuItem(value: gender, child: Text(gender));
                        }).toList(),
                        onChanged: (value) => setState(() => _gender = value!),
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.wc, color: Colors.blue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),

                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Health Status',
                          prefixIcon: Icon(Icons.local_hospital, color: Colors.blue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSaved: (value) => _healthStatus = value!,
                        validator: (value) => value!.isEmpty ? 'Enter health status' : null,
                      ),
                      SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _adoptionStatus,
                        items: ['Available', 'Adopted', 'Pending'].map((status) {
                          return DropdownMenuItem(value: status, child: Text(status));
                        }).toList(),
                        onChanged: (value) => setState(() => _adoptionStatus = value!),
                        decoration: InputDecoration(
                          labelText: 'Adoption Status',
                          prefixIcon: Icon(Icons.assignment_turned_in, color: Colors.blue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),

                      ElevatedButton.icon(
                        onPressed: _addPet,
                        icon: Icon(Icons.add,color: Colors.white,),
                        label: Text('Add Pet',style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // 📋 Pet List
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("petslistning")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(color: Colors.blue));
                }
                final pets = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.pets, size: 30, color: Colors.blue.shade800),
                        ),
                        title: Text(
                          '${pet['type']} (${pet['gender']}, ${pet['age']} yrs)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Health: ${pet['health']}\nStatus: ${pet['status']}',
                          style: TextStyle(color: Colors.black87),
                        ),
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
