import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlogTipsPage extends StatefulWidget {
  const BlogTipsPage({Key? key}) : super(key: key);

  @override
  State<BlogTipsPage> createState() => _BlogTipsPageState();
}

class _BlogTipsPageState extends State<BlogTipsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<String> selectedTags = [];
  List<String> bookmarkedIds = [];
  bool showBookmarksOnly = false;

  final List<Map<String, dynamic>> articles = [
    {
      'id': 'a1',
      'title': 'Basic Puppy Training — Sit & Stay',
      'tags': ['training'],
      'summary': 'Quick steps to teach your puppy sit & stay.',
      'content': 'Step 1: Use treats. Step 2: Be consistent. Step 3: Short sessions...'
    },
    {
      'id': 'a2',
      'title': 'Nutrition 101 for Adult Dogs',
      'tags': ['nutrition'],
      'summary': 'Balanced food choices for dogs.',
      'content': 'Dogs need protein, fats, carbs and micronutrients. Read labels...'
    },
    {
      'id': 'a3',
      'title': 'First Aid: What to do for Cuts',
      'tags': ['first-aid'],
      'summary': 'Immediate steps for small cuts.',
      'content': 'Clean wound with saline, apply pressure, see vet if deep...'
    },
    {
      'id': 'a4',
      'title': 'How to Socialize a Shy Cat',
      'tags': ['behavior', 'training'],
      'summary': 'Gentle trust-building with shy cats.',
      'content': 'Start with quiet space, use treats, avoid forced interactions...'
    },
    {
      'id': 'a5',
      'title': 'Healthy Treats You Can Make',
      'tags': ['nutrition'],
      'summary': 'Vet-safe treat recipes for pets.',
      'content': 'Pumpkin + oats + egg → bake at 180°C for 15 minutes...'
    },
  ];

  final List<String> allTags = ['training', 'nutrition', 'first-aid', 'behavior'];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('bookmarked_articles') ?? [];
    setState(() => bookmarkedIds = ids);
  }

  Future<void> _toggleBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (bookmarkedIds.contains(id)) {
        bookmarkedIds.remove(id);
      } else {
        bookmarkedIds.add(id);
      }
      prefs.setStringList('bookmarked_articles', bookmarkedIds);
    });
  }

  List<Map<String, dynamic>> get filteredArticles {
    final q = _searchCtrl.text.trim().toLowerCase();
    return articles.where((a) {
      if (showBookmarksOnly && !bookmarkedIds.contains(a['id'])) return false;
      if (selectedTags.isNotEmpty &&
          (a['tags'] as List).where((t) => selectedTags.contains(t)).isEmpty) return false;
      if (q.isEmpty) return true;
      final inTitle = (a['title'] as String).toLowerCase().contains(q);
      final inSummary = (a['summary'] as String).toLowerCase().contains(q);
      final inContent = (a['content'] as String).toLowerCase().contains(q);
      return inTitle || inSummary || inContent;
    }).toList();
  }

  void _openArticle(Map<String, dynamic> article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailPage(
          article: article,
          isBookmarked: bookmarkedIds.contains(article['id']),
          onToggleBookmark: () => _toggleBookmark(article['id']),
        ),
      ),
    );
  }

  Widget _tagChip(String tag) {
    final selected = selectedTags.contains(tag);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(tag, style: TextStyle(color: selected ? Colors.white : Colors.blue.shade900)),
        selected: selected,
        backgroundColor: Colors.white.withOpacity(0.7),
        selectedColor: Colors.blue,
        onSelected: (val) {
          setState(() {
            if (val) {
              selectedTags.add(tag);
            } else {
              selectedTags.remove(tag);
            }
          });
        },
        shape: StadiumBorder(side: BorderSide(color: Colors.blue.shade700)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = filteredArticles;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Explore Blogs & Tips', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(showBookmarksOnly ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
            onPressed: () => setState(() => showBookmarksOnly = !showBookmarksOnly),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🌊 Blue Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade200, Colors.blue.shade500],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🌫 Blur Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.15)),
            ),
          ),

          // 📰 Blog Content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 90, 12, 12),
            child: Column(
              children: [
                // 🔍 Search bar
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.blue.shade200, blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search articles...',
                      hintStyle: TextStyle(color: Colors.blue.shade900.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                const SizedBox(height: 12),

                // 🏷 Tags row
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: allTags.map(_tagChip).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // 📚 Articles Grid
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text('No articles found.',
                              style: TextStyle(color: Colors.blue.shade900, fontSize: 16)),
                        )
                      : GridView.builder(
                          itemCount: items.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemBuilder: (context, index) {
                            final a = items[index];
                            final isBook = bookmarkedIds.contains(a['id']);
                            return GestureDetector(
                              onTap: () => _openArticle(a),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white.withOpacity(0.9),
                                  border: Border.all(color: Colors.blue.shade300),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.blue.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4))
                                  ],
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 4,
                                      children: (a['tags'] as List)
                                          .map((t) => Chip(
                                                label: Text(t,
                                                    style: const TextStyle(
                                                        fontSize: 10, color: Colors.white)),
                                                backgroundColor: Colors.blue.shade700,
                                              ))
                                          .toList(),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      a['title'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.blue.shade900),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      a['summary'],
                                      style: TextStyle(color: Colors.blue.shade600, fontSize: 12),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: IconButton(
                                        icon: Icon(isBook ? Icons.bookmark : Icons.bookmark_border,
                                            color: isBook ? Colors.blue.shade700 : Colors.blue.shade400),
                                        onPressed: () => _toggleBookmark(a['id']),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Article Detail Page ----------------
class ArticleDetailPage extends StatelessWidget {
  final Map<String, dynamic> article;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;

  const ArticleDetailPage({
    Key? key,
    required this.article,
    required this.isBookmarked,
    required this.onToggleBookmark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(article['title'],
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
            onPressed: onToggleBookmark,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🌊 Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade200, Colors.blue.shade500],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🌫 Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.15)),
            ),
          ),

          // 📖 Article
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 90, 16, 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: (article['tags'] as List)
                        .map((t) => Chip(
                              label: Text(t, style: const TextStyle(color: Colors.white)),
                              backgroundColor: Colors.blue.shade700,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article['content'],
                    style: const TextStyle(
                        fontSize: 16, height: 1.5, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
