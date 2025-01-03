import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/novel.dart';
import '../../../models/favorite.dart';
import 'chapter_detail_screen.dart';

class NovelDetailScreen extends StatefulWidget {
  final Novel novel;

  const NovelDetailScreen({
    Key? key,
    required this.novel,
  }) : super(key: key);

  @override
  _NovelDetailScreenState createState() => _NovelDetailScreenState();
}

class _NovelDetailScreenState extends State<NovelDetailScreen> {
  bool _isFavorite = false; // Trạng thái yêu thích
  String? _favoriteId; // ID của bản ghi Favorite trong Firestore

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus(); // Kiểm tra trạng thái yêu thích khi khởi tạo
  }

  // Kiểm tra xem novel đã được thêm vào yêu thích hay chưa
  Future<void> _checkFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final isFavorite = await _checkIfFavorite(widget.novel.id, user.uid);
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  // Hàm kiểm tra trạng thái yêu thích trên Firestore
  Future<bool> _checkIfFavorite(String novelId, String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('novelId', isEqualTo: novelId)
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      _favoriteId = snapshot.docs.first.id; // Lưu ID của bản ghi Favorite
      return true;
    }
    return false;
  }

  // Hàm thêm/xóa yêu thích
  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập để thêm vào yêu thích")),
      );
      return;
    }

    if (_isFavorite) {
      // Nếu đã yêu thích, xóa khỏi danh sách yêu thích
      await FirebaseFirestore.instance.collection('favorites').doc(_favoriteId).delete();
      setState(() {
        _isFavorite = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã bỏ yêu thích")),
      );
    } else {
      // Nếu chưa yêu thích, thêm vào danh sách yêu thích
      final favorite = Favorite(
        novelId: widget.novel.id,
        userId: user.uid,
        addedDate: DateTime.now(),
      );
      await FirebaseFirestore.instance.collection('favorites').add(favorite.toJson());
      setState(() {
        _isFavorite = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã thêm vào yêu thích")),
      );
    }
  }

  // Hàm cập nhật lượt xem trong Firestore
  Future<void> _incrementViews() async {
    final novelRef = FirebaseFirestore.instance.collection('novels').doc(widget.novel.id);

    // Tăng lượt xem lên 1
    await novelRef.update({
      'views': FieldValue.increment(1),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoverImage(),
              const SizedBox(height: 16),
              _buildNovelInfo(),
              const SizedBox(height: 16),
              _buildCategories(),
              const SizedBox(height: 16),
              _buildChaptersList(context),
            ],
          ),
        ),
      ),
    );
  }

  // Xây dựng AppBar với icon yêu thích
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.novel.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.deepPurple,
      actions: [
        IconButton(
          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
          color: _isFavorite ? Colors.red : Colors.white,
          onPressed: _toggleFavorite,
        ),
      ],
    );
  }

  // Xây dựng hình ảnh bìa novel
  Widget _buildCoverImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        widget.novel.coverImage,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 300,
            color: Colors.grey[300],
            child: const Icon(Icons.error_outline, size: 50, color: Colors.grey),
          );
        },
      ),
    );
  }

  // Xây dựng thông tin novel
  Widget _buildNovelInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.novel.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tác giả: ${widget.novel.author}',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.remove_red_eye, size: 16, color: Colors.deepPurple),
            const SizedBox(width: 4),
            Text(
              '${widget.novel.views} lượt xem',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  // Xây dựng danh sách các danh mục
  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh mục',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: widget.novel.categories.map((category) {
            return Chip(
              label: Text(
                category,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.deepPurple,
            );
          }).toList(),
        ),
      ],
    );
  }

  // Xây dựng danh sách các chương
  Widget _buildChaptersList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh sách các chương',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.novel.chapters.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final chapter = widget.novel.chapters[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  chapter.title,
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.deepPurple),
                onTap: () {
                  // Tăng lượt xem trước khi điều hướng tới chương chi tiết
                  _incrementViews();
                  _navigateToChapter(context, chapter, index);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // Điều hướng đến màn hình chi tiết chương
  void _navigateToChapter(BuildContext context, dynamic chapter, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterDetailScreen(
          chapter: chapter,
          chapterIndex: index,
          chapters: widget.novel.chapters,
        ),
      ),
    );
  }
}