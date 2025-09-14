import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:uuid/uuid.dart';

class SuccessStories extends StatefulWidget {
  const SuccessStories({Key? key}) : super(key: key);

  @override
  State<SuccessStories> createState() => _SuccessStoriesState();
}

class _SuccessStoriesState extends State<SuccessStories> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController petNameCtrl = TextEditingController();
  final TextEditingController adopterNameCtrl = TextEditingController();
  final TextEditingController storyCtrl = TextEditingController();

  File? _image;

  // Pick image
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  // Submit form
  Future<void> _submitStory() async {
    if (_formKey.currentState!.validate() != null) {
      try {
        await FirebaseFirestore.instance.collection("successStories").add({
          "petName": petNameCtrl.text,
          "adopterName": adopterNameCtrl.text,
          "story": storyCtrl.text,
          "createdAt": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Story submitted successfully!")),
        );

        petNameCtrl.clear();
        adopterNameCtrl.clear();
        storyCtrl.clear();
        setState(() => _image = null);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } else if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a photo")),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool multiline = false}) {
    return TextFormField(
      controller: controller,
      validator: (value) => value == null || value.isEmpty ? "Required" : null,
      maxLines: multiline ? 3 : 1,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background
      appBar: AppBar(
        title: const Text("Success Stories"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField("Pet Name", petNameCtrl),
                  const SizedBox(height: 12),
                  _buildTextField("Adopter Name", adopterNameCtrl),
                  const SizedBox(height: 12),
                  _buildTextField("Short Story", storyCtrl, multiline: true),
                  const SizedBox(height: 12),

                  // Image Preview
                  _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, height: 150, fit: BoxFit.cover),
                        )
                      : const Text("📷 No image selected",
                          style: TextStyle(color: Colors.grey)),

                  const SizedBox(height: 12),

                  // Upload Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.photo),
                    label: const Text("Upload Photo"),
                    onPressed: _pickImage,
                  ),

                  const SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: _submitStory,
                    child: const Text("Submit Story"),
                  ),
                ],
              ),
            ),
            const Divider(height: 40, thickness: 1),

            // Gallery Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.pets, color: Colors.blue),
                SizedBox(width: 6),
                Text(
                  "Gallery of Happy Adoptions",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Live list from Firestore
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("successStories")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final docs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final story = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (story['imageUrl'] != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              child: Image.network(
                                story['imageUrl'],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "🐶 ${story['petName']} adopted by ${story['adopterName']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  story['story'],
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
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
