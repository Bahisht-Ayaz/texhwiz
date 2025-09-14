import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_eproject/petownwer/petform.dart'; // 👈 form page ka import

class PetListPage extends StatefulWidget {
  const PetListPage({super.key});

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  final petsRef = FirebaseFirestore.instance.collection("pets");

  // 🔹 Delete Pet
  Future<void> _deletePet(String id) async {
    await petsRef.doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pet deleted")),
    );
  }

  // 🔹 Edit Pet (Navigate to form with existing data)
  void _editPet(DocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PetProfileFormPage(petDoc: doc), // 👈 send doc for editing
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pets"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // 🔹 FAB to add new pet
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PetProfileFormPage()), // 👈 add mode
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: petsRef.orderBy("createdAt", descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pets found!"));
          }

          final pets = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final doc = pets[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: data["photoUrl"] != null
                        ? NetworkImage(data["photoUrl"])
                        : null,
                    backgroundColor: Colors.blue.shade100,
                    child: data["photoUrl"] == null
                        ? const Icon(Icons.pets, color: Colors.blue)
                        : null,
                  ),
                  title: Text(
                    data["name"] ?? "Unknown",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Breed: ${data["breed"] ?? "N/A"}\n"
                    "Age: ${data["age"] ?? "N/A"} yrs\n"
                    "Health: ${data["healthStatus"] ?? "N/A"}",
                  ),
                  isThreeLine: true,

                  // 🔹 CRUD Buttons
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "edit") {
                        _editPet(doc); // 👈 open edit form
                      } else if (value == "delete") {
                        _deletePet(doc.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "edit",
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text("Edit"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: "delete",
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Delete"),
                          ],
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
