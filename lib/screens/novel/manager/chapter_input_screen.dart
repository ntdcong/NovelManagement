import 'package:flutter/material.dart';
import '../../../models/chapter.dart';

class ChapterInputScreen extends StatefulWidget {
  @override
  _ChapterInputScreenState createState() => _ChapterInputScreenState();
}

class _ChapterInputScreenState extends State<ChapterInputScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _saveChapter() {
    final chapter = Chapter(
      id: DateTime.now().toString(),
      title: _titleController.text,
      content: _contentController.text,
    );
    Navigator.pop(context, chapter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nhập Chương'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Tiêu đề chương'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Nội dung chương'),
              maxLines: 10,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChapter,
              child: Text('Lưu Chương'),
            ),
          ],
        ),
      ),
    );
  }
}
