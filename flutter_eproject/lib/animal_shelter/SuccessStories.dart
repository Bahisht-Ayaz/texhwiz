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
        // 🔹 Upload image to Firebase Storage
        // String fileId = const Uuid().v4();
        // final ref = FirebaseStorage.instance.ref().child("stories/$fileId.jpg");
        // await ref.putFile(_image!);
        // String imageUrl = await ref.getDownloadURL();

        // 🔹 Save story in Firestore
        await FirebaseFirestore.instance.collection("successStories").add({
          "petName": petNameCtrl.text,
          "adopterName": adopterNameCtrl.text,
          "story": storyCtrl.text,
          // "imageUrl": imageUrl,
          "createdAt": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Story submitted successfully!")),
        );

        // Clear form
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Success Stories"),
        backgroundColor: Colors.red,
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
                  _image != null
                      ? Image.file(_image!, height: 120)
                      : const Text("No image selected"),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text("Upload Photo"),
                    onPressed: _pickImage,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    onPressed: _submitStory,
                    child: const Text("Submit Story"),
                  ),
                ],
              ),
            ),
            const Divider(height: 30),
            const Text(
              "🐾 Gallery of Happy Adoptions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),

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
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (story['imageUrl'] != null)
                            Image.network(story['imageUrl'],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "🐶 ${story['petName']} adopted by ${story['adopterName']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(story['story']),
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
