import 'package:flutter/material.dart';
import 'package:doc_quan_ly_tieu_thuyet/models/novel.dart';

class UpdateNovelDialog extends StatefulWidget {
  final Novel novel;
  final Function(Novel) onUpdate;

  UpdateNovelDialog({required this.novel, required this.onUpdate});

  @override
  _UpdateNovelDialogState createState() => _UpdateNovelDialogState();
}

class _UpdateNovelDialogState extends State<UpdateNovelDialog> {
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _coverImageController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.novel.title);
    _authorController = TextEditingController(text: widget.novel.author);
    _coverImageController = TextEditingController(text: widget.novel.coverImage);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _coverImageController.dispose();
    super.dispose();
  }

  void _updateNovel() {
    final updatedNovel = Novel(
      id: widget.novel.id,
      title: _titleController.text,
      author: _authorController.text,
      uid: widget.novel.uid,
      views: widget.novel.views,
      coverImage: _coverImageController.text,
      chapters: widget.novel.chapters, // Giữ nguyên danh sách chương
    );
    widget.onUpdate(updatedNovel);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cập nhật thông tin truyện'),
      content: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Tên truyện'),
          ),
          TextField(
            controller: _authorController,
            decoration: InputDecoration(labelText: 'Tác giả'),
          ),
          TextField(
            controller: _coverImageController,
            decoration: InputDecoration(labelText: 'URL ảnh bìa'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
        ),
        TextButton(
          onPressed: _updateNovel,
          child: Text('Cập nhật'),
        ),
      ],
    );
  }
}
