import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class PetProfileFormPage extends StatefulWidget {
  final DocumentSnapshot? petDoc; // 👈 agar edit ho to data milega

  const PetProfileFormPage({super.key, this.petDoc});

  @override
  State<PetProfileFormPage> createState() => _PetProfileFormPageState();
}

class _PetProfileFormPageState extends State<PetProfileFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameC = TextEditingController();
  final ageC = TextEditingController();
  final breedC = TextEditingController();
  final speciesC = TextEditingController();
  final genderC = TextEditingController();
  final healthC = TextEditingController();

  File? _image;
  String? existingPhotoUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // 👇 Agar edit ho to fields fill karo
    if (widget.petDoc != null) {
      final data = widget.petDoc!.data() as Map<String, dynamic>;
      nameC.text = data["name"] ?? "";
      ageC.text = data["age"]?.toString() ?? "";
      breedC.text = data["breed"] ?? "";
      speciesC.text = data["species"] ?? "";
      genderC.text = data["gender"] ?? "";
      healthC.text = data["healthStatus"] ?? "";
      existingPhotoUrl = data["photoUrl"];
    }
  }

  // 📸 Pick Image
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  // ☁ Upload Image to Firebase Storage
  Future<String?> _uploadImage(File file) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("pet_photos")
          .child("${DateTime.now().millisecondsSinceEpoch}.jpg");
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Image upload error: $e");
      return null;
    }
  }

  // 📝 Save / Update Pet
  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in!")),
      );
      return;
    }

    setState(() => _loading = true);

    String? photoUrl = existingPhotoUrl;
    if (_image != null) {
      photoUrl = await _uploadImage(_image!);
    }

    final petData = {
      "userId": uid,
      "name": nameC.text.trim(),
      "age": int.tryParse(ageC.text) ?? 0,
      "breed": breedC.text.trim(),
      "species": speciesC.text.trim(),
      "gender": genderC.text.trim(),
      "photoUrl": photoUrl,
      "healthStatus": healthC.text.trim(),
      "updatedAt": FieldValue.serverTimestamp(),
    };

    try {
      if (widget.petDoc == null) {
        // ➕ New Pet
        petData["createdAt"] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection("pets").add(petData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pet profile added successfully!")),
        );
      } else {
        // ✏ Update Pet
        await widget.petDoc!.reference.update(petData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pet profile updated successfully!")),
        );
      }

      Navigator.pop(context); // Back after save
    } catch (e) {
      debugPrint("Save error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.petDoc != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Pet Profile" : "Add Pet Profile"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🖼 Pet Image
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (existingPhotoUrl != null
                          ? NetworkImage(existingPhotoUrl!)
                          : null) as ImageProvider?,
                  backgroundColor: Colors.blue.shade100,
                  child: (_image == null && existingPhotoUrl == null)
                      ? const Icon(Icons.add_a_photo,
                          size: 40, color: Colors.blue)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Form Fields
              _buildTextField(controller: nameC, label: "Pet Name", validator: true),
              _buildTextField(controller: ageC, label: "Age", keyboard: TextInputType.number),
              _buildTextField(controller: breedC, label: "Breed"),
              _buildTextField(controller: speciesC, label: "Species"),
              _buildTextField(controller: genderC, label: "Gender"),
              _buildTextField(controller: healthC, label: "Health Status"),

              const SizedBox(height: 20),

              // Save Button
              _loading
                  ? const CircularProgressIndicator(color: Colors.blue)
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _savePet,
                      icon: Icon(isEdit ? Icons.update : Icons.save),
                      label: Text(isEdit ? "Update Pet" : "Save Pet"),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool validator = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.blue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: validator
            ? (val) => val == null || val.isEmpty ? "Enter $label" : null
            : null,
      ),
    );
  }
}
