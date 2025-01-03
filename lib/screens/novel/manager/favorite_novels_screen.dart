import 'package:doc_quan_ly_tieu_thuyet/screens/novel/read/novel_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../../../../services/firestore_service.dart';
import '../../../../../models/novel.dart';

class FavoriteNovelsScreen extends StatefulWidget {
  final String userId;

  const FavoriteNovelsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteNovelsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Novel> favoriteNovels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final favorites = await _firestoreService.getUserFavorites(widget.userId);
      final allNovels = await _firestoreService.getNovels();

      setState(() {
        favoriteNovels = allNovels
            .where((novel) => favorites.any((fav) => fav.novelId == novel.id))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra khi tải danh sách yêu thích')),
      );
    }
  }

  Future<void> _removeFavorite(Novel novel) async {
    try {
      await _firestoreService.removeFavorite(widget.userId, novel.id);
      setState(() {
        favoriteNovels.removeWhere((n) => n.id == novel.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa "${novel.title}" khỏi danh sách yêu thích'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () async {
              await _firestoreService.addFavorite(
                widget.userId,
                novel.id,
              );
              await loadFavorites();
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra khi xóa khỏi danh sách yêu thích')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiểu Thuyết Yêu Thích'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadFavorites,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteNovels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Chưa có tiểu thuyết yêu thích nào',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: favoriteNovels.length,
                    itemBuilder: (context, index) {
                      final novel = favoriteNovels[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: novel.coverImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    novel.coverImage,
                                    width: 50,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.book, size: 50),
                                  ),
                                )
                              : const Icon(Icons.book, size: 50),
                          title: Text(
                            novel.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tác giả: ${novel.author}'),
                              Text('Số chương: ${novel.chapters.length}'),
                              Text('Lượt đọc: ${novel.views}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () => _removeFavorite(novel),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NovelDetailScreen(novel: novel),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}