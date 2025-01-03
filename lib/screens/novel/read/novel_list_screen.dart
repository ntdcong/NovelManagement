import 'package:doc_quan_ly_tieu_thuyet/models/chapter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/novel.dart';
import 'novel_detail_screen.dart';

class NovelListScreen extends StatefulWidget {
  const NovelListScreen({super.key});

  @override
  State<NovelListScreen> createState() => _NovelListScreenState();
}

class _NovelListScreenState extends State<NovelListScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();

  List<Novel> _allNovels = [];
  List<Novel> _filteredNovels = [];
  bool _isGridView = true;
  String _sortBy = 'views';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => _filterAndSortNovels());
    _loadNovels();
  }

  Future<void> _loadNovels() async {
    final snapshot = await _firestore.collection('novels').get();
    setState(() {
      _allNovels = snapshot.docs.map((doc) {
        final data = doc.data();
        return Novel(
          id: doc.id,
          title: data['title'] ?? '',
          author: data['author'] ?? '',
          views: data['views'] ?? 0,
          coverImage: data['coverImage'] ?? '',
          chapters: (data['chapters'] as List<dynamic>?)
                  ?.map((chapter) => Chapter(
                      id: chapter['id'] ?? '',
                      title: chapter['title'] ?? '',
                      content: chapter['content'] ?? ''))
                  .toList() ??
              [],
          uid: data['uid'] ?? '',
          categories: (data['categories'] as List<dynamic>?)
                  ?.map((category) => category.toString())
                  .toList() ??
              [],
        );
      }).toList();
      _filterAndSortNovels();
    });
  }

  void _filterAndSortNovels() {
    setState(() {
      _filteredNovels = _allNovels.where((novel) {
        final searchTerm = _searchController.text.toLowerCase();
        final matchesSearch = novel.title.toLowerCase().contains(searchTerm) ||
            novel.author.toLowerCase().contains(searchTerm);
        return matchesSearch &&
            (_selectedCategory == null ||
                novel.categories.contains(_selectedCategory));
      }).toList();

      _filteredNovels.sort((a, b) => _sortBy == 'views'
          ? b.views.compareTo(a.views)
          : a.title.compareTo(b.title));
    });
  }

  Widget _buildNovelCard(Novel novel, {bool isGrid = true}) {
    final coverImage = Image.network(
      novel.coverImage,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _buildPlaceholder(isError: false),
      errorBuilder: (_, __, ___) => _buildPlaceholder(isError: true),
    );

    final novelInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          novel.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          novel.author,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.remove_red_eye, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text('${novel.views}', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ],
    );

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NovelDetailScreen(novel: novel)),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: isGrid
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: SizedBox(
                        height: 150, width: double.infinity, child: coverImage),
                  ),
                  Padding(padding: const EdgeInsets.all(8), child: novelInfo),
                ],
              )
            : ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(width: 60, height: 80, child: coverImage),
                ),
                title: Text(novel.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(novel.author),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.remove_red_eye, size: 16),
                    const SizedBox(width: 4),
                    Text('${novel.views}'),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPlaceholder({required bool isError}) {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.book,
            color: Colors.grey[600],
            size: isError ? 30 : 50,
          ),
          if (isError) ...[
            const SizedBox(height: 4),
            Text(
              'Lỗi tải ảnh',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Thư Viện Truyện',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm truyện...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Lọc theo danh mục',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Tất cả')),
                          ..._allNovels
                              .expand((novel) => novel.categories)
                              .toSet()
                              .map((category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                            _filterAndSortNovels();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sortBy,
                        decoration: const InputDecoration(
                          labelText: 'Sắp xếp theo',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'views', child: Text('Lượt xem')),
                          DropdownMenuItem(value: 'title', child: Text('Tên')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                            _filterAndSortNovels();
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
            child: _isGridView
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredNovels.length,
                    itemBuilder: (_, index) =>
                        _buildNovelCard(_filteredNovels[index]),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNovels.length,
                    itemBuilder: (_, index) =>
                        _buildNovelCard(_filteredNovels[index], isGrid: false),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
