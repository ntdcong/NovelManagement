import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/novel.dart';
import 'novel_detail_screen.dart';
import '../models/chapter.dart';

class NovelListScreen extends StatefulWidget {
  @override
  _NovelListScreenState createState() => _NovelListScreenState();
}

class _NovelListScreenState extends State<NovelListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy UID của người dùng hiện tại
  String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<List<Novel>> fetchNovels() async {
    final snapshot = await _firestore
        .collection('novels')
        .where('uid', isEqualTo: currentUserUid)  // Lọc theo UID
        .get();

    return snapshot.docs.map((doc) {
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
                      content: chapter['content'] ?? '',
                    ))
                .toList() ??
            [],
        uid: currentUserUid,
      );
    }).toList();
  }

  // Cập nhật truyện
  Future<void> _updateNovel(Novel novel) async {
    if (novel.id.isEmpty) {
      print("ID truyện không hợp lệ, không thể cập nhật");
      return;
    }

    try {
      print("Đang cập nhật truyện với ID: ${novel.id}");
      await FirebaseFirestore.instance
          .collection('novels')
          .doc(novel.id)  // Sử dụng ID của truyện
          .update(novel.toMap());
      print("Cập nhật truyện thành công");
    } catch (e) {
      print("Lỗi khi cập nhật truyện: $e");
    }
  }

  // Xoá truyện
  Future<void> _deleteNovel(String novelId) async {
    if (novelId.isEmpty) {
      print("ID truyện không hợp lệ, không thể xóa");
      return;
    }

    try {
      print("Đang xoá truyện với ID: $novelId");
      await FirebaseFirestore.instance
          .collection('novels')
          .doc(novelId)  // Xoá theo ID truyện
          .delete();
      setState(() {
        // Cập nhật lại danh sách sau khi xóa
        fetchNovels();
      });
      print("Xoá truyện thành công");
    } catch (e) {
      print("Lỗi khi xoá truyện: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Tiểu Thuyết'),
      ),
      body: FutureBuilder<List<Novel>>(
        future: fetchNovels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Chưa có tiểu thuyết nào.'));
          }

          final novels = snapshot.data!;
          return ListView.builder(
            itemCount: novels.length,
            itemBuilder: (context, index) {
              final novel = novels[index];
              return ListTile(
                leading: Image.network(
                  novel.coverImage,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(novel.title),
                subtitle: Text('Lượt đọc: ${novel.views}'),
                trailing: PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'update') {
                      _updateNovel(novel); // Cập nhật truyện
                    } else if (value == 'delete') {
                      _deleteNovel(novel.id); // Xoá truyện
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'update',
                      child: Text('Cập nhật'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Xoá'),
                    ),
                  ],
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
          );
        },
      ),
    );
  }
}
