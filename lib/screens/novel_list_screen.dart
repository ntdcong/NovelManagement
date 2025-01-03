import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/novel.dart';
import 'novel_detail_screen.dart';
import '../models/chapter.dart';

class NovelListScreen extends StatefulWidget {
  @override
  _NovelListScreenState createState() => _NovelListScreenState();
}

class _NovelListScreenState extends State<NovelListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  List<Novel> _allNovels = [];
  List<Novel> _filteredNovels = [];
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadNovels();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadNovels() async {
    final novels = await fetchNovels();
    setState(() {
      _allNovels = novels;
      _filteredNovels = novels;
    });
  }

  void _onSearchChanged() {
    filterNovels();
  }

  void filterNovels() {
    setState(() {
      _filteredNovels = _allNovels.where((novel) {
        return novel.title.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            novel.author.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );
      }).toList();
    });
  }

  Future<List<Novel>> fetchNovels() async {
    final snapshot = await _firestore.collection('novels').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Novel(
        id: doc.id,
        title: data['title'] ?? '',
        author: data['author'] ?? '',
        views: data['views'] ?? 0,
        coverImage: data['coverImage'] ?? '',
        chapters: (data['chapters'] as List<dynamic>?)?.
            map((chapter) => Chapter(
                      id: chapter['id'] ?? '',
                      title: chapter['title'] ?? '',
                      content: chapter['content'] ?? '',
                    ))
                .toList() ?? [],
        uid: '',
      );
    }).toList();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.book,
        color: Colors.grey[600],
        size: 50,
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.grey[600],
            size: 30,
          ),
          SizedBox(height: 4),
          Text(
            'Lỗi tải ảnh',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Thư Viện Truyện',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm truyện...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: _isGridView ? _buildGridView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredNovels.length,
      itemBuilder: (context, index) {
        final novel = _filteredNovels[index];
        return InkWell(
          onTap: () => _navigateToDetail(novel),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    novel.coverImage,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildImagePlaceholder();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorImage();
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        novel.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        novel.author,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.remove_red_eye,
                              size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            '${novel.views}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredNovels.length,
      itemBuilder: (context, index) {
        final novel = _filteredNovels[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _navigateToDetail(novel),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      novel.coverImage,
                      width: 100,
                      height: 140,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildImagePlaceholder();
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildErrorImage();
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          novel.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          novel.author,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.remove_red_eye,
                                size: 16, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              '${novel.views}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToDetail(Novel novel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelDetailScreen(novel: novel),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
