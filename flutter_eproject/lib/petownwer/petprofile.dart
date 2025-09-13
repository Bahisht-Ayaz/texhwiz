import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class PetProfilesPage extends StatefulWidget {
  const PetProfilesPage({super.key});

  @override
  State<PetProfilesPage> createState() => _PetProfilesPageState();
}

class _PetProfilesPageState extends State<PetProfilesPage> {
  File? _image;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("pet_photos")
          .child("${DateTime.now().millisecondsSinceEpoch}.jpg");
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  void _showPetForm({DocumentSnapshot? doc}) {
    final data = doc?.data() as Map<String, dynamic>? ?? {};
    final nameC = TextEditingController(text: data["name"]);
    final ageC = TextEditingController(text: data["age"]?.toString() ?? "");
    final breedC = TextEditingController(text: data["breed"]);
    final speciesC = TextEditingController(text: data["species"]);
    final genderC = TextEditingController(text: data["gender"]);
    final healthC = TextEditingController(text: data["healthStatus"]);

    _image = null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(doc == null ? "Add Pet" : "Edit Pet"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.add_a_photo, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              TextField(controller: nameC, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: ageC, decoration: const InputDecoration(labelText: "Age"), keyboardType: TextInputType.number),
              TextField(controller: breedC, decoration: const InputDecoration(labelText: "Breed")),
              TextField(controller: speciesC, decoration: const InputDecoration(labelText: "Species")),
              TextField(controller: genderC, decoration: const InputDecoration(labelText: "Gender")),
              TextField(controller: healthC, decoration: const InputDecoration(labelText: "Health Status")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              String? photoUrl = data["photoUrl"];
              if (_image != null) {
                photoUrl = await _uploadImage(_image!);
              }

              final petData = {
                "userId": FirebaseAuth.instance.currentUser!.uid,
                "name": nameC.text,
                "age": int.tryParse(ageC.text) ?? 0,
                "breed": breedC.text,
                "species": speciesC.text,
                "gender": genderC.text,
                "photoUrl": photoUrl,
                "healthStatus": healthC.text,
                "createdAt": FieldValue.serverTimestamp(),
              };

              if (doc == null) {
                await FirebaseFirestore.instance.collection("pets").add(petData);
              } else {
                await FirebaseFirestore.instance.collection("pets").doc(doc.id).update(petData);
              }

              Navigator.pop(context);
            },
            child: Text(doc == null ? "Save" : "Update"),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePet(String id) async {
    await FirebaseFirestore.instance.collection("pets").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Pets"), backgroundColor: Colors.teal),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("pets")
            .where("userId", isEqualTo: uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No pets added yet"));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final pet = docs[i].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: pet["photoUrl"] != null
                      ? CircleAvatar(backgroundImage: NetworkImage(pet["photoUrl"]))
                      : const CircleAvatar(child: Icon(Icons.pets)),
                  title: Text("${pet["name"]} (${pet["species"]})"),
                  subtitle: Text("Breed: ${pet["breed"]}\nAge: ${pet["age"]}\nHealth: ${pet["healthStatus"]}"),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == "Edit") _showPetForm(doc: docs[i]);
                      if (val == "Delete") _deletePet(docs[i].id);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: "Edit", child: Text("Edit")),
                      const PopupMenuItem(value: "Delete", child: Text("Delete")),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPetForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
