import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPetStorePage extends StatefulWidget {
  const AdminPetStorePage({super.key});

  @override
  State<AdminPetStorePage> createState() => _AdminPetStorePageState();
}

class _AdminPetStorePageState extends State<AdminPetStorePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _imageCtrl = TextEditingController();
  final TextEditingController _storeLinkCtrl = TextEditingController();

  String _selectedCategory = "Food";

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection("pet_store").add({
        "name": _nameCtrl.text.trim(),
        "price": int.tryParse(_priceCtrl.text.trim()) ?? 0,
        "category": _selectedCategory,
        "imageUrl": _imageCtrl.text.trim(),
        "storeLink": _storeLinkCtrl.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Product added successfully")),
      );

      _nameCtrl.clear();
      _priceCtrl.clear();
      _imageCtrl.clear();
      _storeLinkCtrl.clear();
      setState(() => _selectedCategory = "Food");
    }
  }

  Future<void> _deleteProduct(String id) async {
    await FirebaseFirestore.instance.collection("pet_store").doc(id).delete();
  }

  Future<void> _editProduct(String id, String currentName, int currentPrice) async {
    final nameCtrl = TextEditingController(text: currentName);
    final priceCtrl = TextEditingController(text: currentPrice.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("✏️ Edit Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            const SizedBox(height: 10),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection("pet_store").doc(id).update({
                "name": nameCtrl.text.trim(),
                "price": int.tryParse(priceCtrl.text.trim()) ?? 0,
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProductsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("pet_store")
              .orderBy("createdAt", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = snapshot.data!.docs;

            if (products.isEmpty) {
              return const Center(
                child: Text("🚫 No products added yet", style: TextStyle(fontSize: 16)),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final data = product.data() as Map<String, dynamic>;
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: data["imageUrl"] != ""
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(data["imageUrl"],
                                width: 50, height: 50, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.pets, size: 40, color: Colors.blueAccent),
                    title: Text("${data["name"]} (PKR ${data["price"]})",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("📦 ${data["category"]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editProduct(product.id, data["name"], data["price"]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(product.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Admin - Pet Store"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 10, spreadRadius: 5),
            ],
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  "➕ Add New Product",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _inputDecoration("Product Name", Icons.shopping_bag),
                  validator: (val) => val!.isEmpty ? "Enter product name" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceCtrl,
                  decoration: _inputDecoration("Price (PKR)", Icons.attach_money),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? "Enter product price" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: ["Food", "Grooming", "Toys", "Health"]
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                  decoration: _inputDecoration("Category", Icons.category),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageCtrl,
                  decoration: _inputDecoration("Image URL (optional)", Icons.image),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _storeLinkCtrl,
                  decoration: _inputDecoration("Store Link", Icons.link),
                ),
                const SizedBox(height: 25),

                // Add Product Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add Product"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _addProduct,
                  ),
                ),
                const SizedBox(height: 12),

                // View Products Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.list),
                    label: const Text("View Products"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      side: const BorderSide(color: Colors.blueAccent, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _showProductsList,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
