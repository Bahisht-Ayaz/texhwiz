import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  String searchQuery = "";

  Future<void> bookmarkArticle(String articleId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection("bookmarks").add({
      "userId": uid,
      "articleId": articleId,
      "createdAt": FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Article bookmarked")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text(
          "Pet Care Articles",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔍 Search Box
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by title or tag...",
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() => searchQuery = val.toLowerCase());
              },
            ),
          ),

          // 🔹 Articles List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("articles")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data["title"] ?? "").toString().toLowerCase();
                  final tags = (data["tags"] as List<dynamic>? ?? [])
                      .map((e) => e.toString().toLowerCase())
                      .toList();
                  return title.contains(searchQuery) ||
                      tags.any((tag) => tag.contains(searchQuery));
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                      child: Text(
                    "No articles found",
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ));
                }

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      shadowColor: Colors.blueAccent.withOpacity(0.3),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          data["title"] ?? "No Title",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            (data["content"] ?? "")
                                .toString()
                                .substring(
                                    0,
                                    ((data["content"] ?? "")
                                                .toString()
                                                .length >
                                            70
                                        ? 70
                                        : (data["content"] ?? "")
                                            .toString()
                                            .length)),
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.bookmark_border,
                              color: Colors.blueAccent),
                          onPressed: () => bookmarkArticle(doc.id),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArticleDetailPage(
                                title: data["title"] ?? "No Title",
                                content: data["content"] ?? "",
                                tags: List<String>.from(data["tags"] ?? []),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final List<String> tags;

  const ArticleDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(content,
                  style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 16),
              const Text("Tags:",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: tags.map((tag) {
                  return Chip(
                    label: Text(tag,
                        style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.blueAccent,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
