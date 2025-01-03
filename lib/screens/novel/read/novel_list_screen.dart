import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/novel.dart';
import 'novel_detail_screen.dart';
import '../../../models/chapter.dart';

class NovelListScreen extends StatefulWidget {
  @override
  _NovelListScreenState createState() => _NovelListScreenState();
}

class _NovelListScreenState extends State<NovelListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Novel> _allNovels = [];
  List<Novel> _filteredNovels = [];
  bool _isGridView = true;
  String _sortBy = 'views';
  String? _selectedCategory;

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
      _sortNovels();
    });
  }

  void _onSearchChanged() {
    filterNovels();
  }

  void filterNovels() {
    setState(() {
      _filteredNovels = _allNovels.where((novel) {
        final matchesSearch = novel.title.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                novel.author.toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    );

        final matchesCategory = _selectedCategory == null ||
            novel.categories.contains(_selectedCategory);

        return matchesSearch && matchesCategory;
      }).toList();
      _sortNovels();
    });
  }

  void _sortNovels() {
    setState(() {
      if (_sortBy == 'views') {
        _filteredNovels.sort((a, b) => b.views.compareTo(a.views));
      } else if (_sortBy == 'title') {
        _filteredNovels.sort((a, b) => a.title.compareTo(b.title));
      }
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
            map((chapter) => Chapter(id: chapter['id'] ?? '', title: chapter['title'] ?? '', content: chapter['content'] ?? ''))
            .toList() ?? [],
        uid: data['uid'] ?? '',
        categories: (data['categories'] as List<dynamic>?)?.
            map((category) => category.toString()).toList() ?? [],
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
            padding: EdgeInsets.all(12),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                TextField(
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
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Lọc theo danh mục',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text('Tất cả')),
                          ..._allNovels
                              .expand((novel) => novel.categories)
                              .toSet()
                              .map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                            filterNovels();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sortBy,
                        decoration: InputDecoration(
                          labelText: 'Sắp xếp theo',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: 'views', child: Text('Lượt xem')),
                          DropdownMenuItem(value: 'title', child: Text('Tên')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                            _sortNovels();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
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
        return InkWell(
          onTap: () => _navigateToDetail(novel),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  novel.coverImage,
                  width: 60,
                  height: 80,
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
              title: Text(
                novel.title,
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                novel.author,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove_red_eye, size: 16),
                  SizedBox(width: 4),
                  Text('${novel.views}'),
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
}
