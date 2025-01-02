import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/novel.dart';
import 'novel_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  final String userId;

  FavoriteScreen({required this.userId});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Novel> favoriteNovels = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final favorites = await _firestoreService.getUserFavorites(widget.userId);

    // Giả sử bạn đã có danh sách tất cả các tiểu thuyết
    final allNovels = await _firestoreService.getNovels();

    setState(() {
      favoriteNovels = allNovels.where((novel) {
        return favorites.any((fav) => fav.novelId == novel.id);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tiểu Thuyết Yêu Thích'),
      ),
      body: ListView.builder(
        itemCount: favoriteNovels.length,
        itemBuilder: (context, index) {
          final novel = favoriteNovels[index];
          return ListTile(
            title: Text(novel.title),
            subtitle: Text('Lượt đọc: ${novel.views}'),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _firestoreService.removeFavorite(widget.userId, novel.id);
                loadFavorites();
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NovelDetailScreen(novel: novel),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
