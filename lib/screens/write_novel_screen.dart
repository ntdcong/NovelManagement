import 'package:doc_quan_ly_tieu_thuyet/models/user.dart' as local_user;
import 'package:doc_quan_ly_tieu_thuyet/screens/edit_novel_screen.dart';
import 'package:doc_quan_ly_tieu_thuyet/screens/manage_novels_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/novel.dart';
import '../services/firestore_service.dart';
import 'chapter_input_screen.dart';
import '../models/chapter.dart';

class WriteNovelScreen extends StatefulWidget {
  @override
  _WriteNovelScreenState createState() => _WriteNovelScreenState();
}

class _WriteNovelScreenState extends State<WriteNovelScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _coverImageController = TextEditingController();
  final List<Chapter> _chapters = [];
  final FirestoreService _firestoreService = FirestoreService();

  void _addChapter() async {
    final chapter = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterInputScreen(),
      ),
    );

    if (chapter != null) {
      setState(() {
        _chapters.add(chapter);
      });
    }
  }

  Future<void> _publishNovel() async {
    final User? user =
        FirebaseAuth.instance.currentUser; // Lấy thông tin người dùng
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bạn cần đăng nhập để đăng tiểu thuyết.')),
      );
      return;
    }

    final novel = Novel(
      id: '', // Firestore sẽ tự động sinh ID
      title: _titleController.text,
      author: _authorController.text,
      views: 0,
      coverImage: _coverImageController.text,
      chapters: _chapters,
      uid: user.uid, // Lưu UID của người viết
    );

    await _firestoreService.addNovel(novel);

    // Chuyển đến màn hình EditNovelScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageNovelsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viết Tiểu Thuyết'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Tiêu đề'),
            ),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(labelText: 'Tác giả'),
            ),
            TextField(
              controller: _coverImageController,
              decoration: InputDecoration(labelText: 'URL ảnh bìa'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addChapter,
              child: Text('Thêm Chương'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _publishNovel,
              child: Text('Publish Tiểu Thuyết'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _chapters.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_chapters[index].title),
                    subtitle: Text(_chapters[index].content),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
