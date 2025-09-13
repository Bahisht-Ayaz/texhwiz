import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class PetStorePage extends StatefulWidget {
  const PetStorePage({super.key});

  @override
  State<PetStorePage> createState() => _PetStorePageState();
}

class _PetStorePageState extends State<PetStorePage> {
  String _selectedCategory = "All";

  Future<void> _addToWishlist(
      Map<String, dynamic> product, String productId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("wishlists")
        .doc(uid)
        .collection("items")
        .doc(productId)
        .set(product);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Added to Wishlist")),
    );
  }

  Future<void> _openStoreLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Pet Store",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔹 Category Filter (Chips)
          Container(
            height: 55,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ["All", "Food", "Grooming", "Toys", "Health"]
                  .map((cat) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          label: Text(cat,
                              style: TextStyle(
                                  color: _selectedCategory == cat
                                      ? Colors.white
                                      : Colors.blueAccent)),
                          selected: _selectedCategory == cat,
                          selectedColor: Colors.blueAccent,
                          backgroundColor: Colors.white,
                          onSelected: (val) {
                            setState(() => _selectedCategory = cat);
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),

          // 🔹 Products Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedCategory == "All"
                  ? FirebaseFirestore.instance
                      .collection("pet_store")
                      .orderBy("createdAt", descending: true)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection("pet_store")
                      .where("category", isEqualTo: _selectedCategory)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                      child: Text("No products available",
                          style: TextStyle(
                              fontSize: 16, color: Colors.blueGrey)));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final product = docs[i].data() as Map<String, dynamic>;
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: Colors.blueAccent.withOpacity(0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 Product Image
                          Expanded(
                            child: product["imageUrl"] != null
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: Image.network(
                                      product["imageUrl"],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.pets,
                                        size: 50, color: Colors.blueAccent)),
                          ),

                          // 🔹 Product Details
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            child: Text(
                              product["name"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "PKR ${product["price"]}",
                              style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),

                          const Spacer(),

                          // 🔹 Buttons Row
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  tooltip: "Add to Wishlist",
                                  icon: const Icon(Icons.favorite_border,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _addToWishlist(product, docs[i].id),
                                ),
                                IconButton(
                                  tooltip: "Buy Now",
                                  icon: const Icon(Icons.shopping_cart,
                                      color: Colors.blueAccent),
                                  onPressed: () =>
                                      _openStoreLink(product["storeLink"]),
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
          ),
        ],
      ),
    );
  }
}
