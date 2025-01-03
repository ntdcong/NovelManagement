import 'package:flutter/material.dart';
import '../../../models/chapter.dart';

class ChapterInputScreen extends StatefulWidget {
  @override
  _ChapterInputScreenState createState() => _ChapterInputScreenState();
}

class _ChapterInputScreenState extends State<ChapterInputScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _saveChapter() {
    if (_formKey.currentState!.validate()) {
      final chapter = Chapter(
        id: DateTime.now().toString(),
        title: _titleController.text,
        content: _contentController.text,
      );
      Navigator.pop(context, chapter);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chương đã được thêm thành công!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập Chương'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề chương',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề chương';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung chương',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung chương';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChapter,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Lưu Chương'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}