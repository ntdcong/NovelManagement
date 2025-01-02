import 'package:flutter/material.dart';
import '../models/novel.dart';
import '../services/firestore_service.dart';
import 'chapter_input_screen.dart';

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
    final novel = Novel(
      id: '',
      title: _titleController.text,
      author: _authorController.text,
      views: 0,
      coverImage: _coverImageController.text,
      chapters: _chapters,
    );

    await _firestoreService.addNovel(novel);
    Navigator.pop(context);  // Quay lại màn hình trước sau khi publish
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
