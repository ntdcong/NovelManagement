import 'package:doc_quan_ly_tieu_thuyet/screens/novel/manager/manage_novels_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../models/novel.dart';
import '../../../../../services/firestore_service.dart';
import 'chapter_input_screen.dart';
import '../../../../../models/chapter.dart';
import '../../../../../models/category.dart'; // Import model Category
import '../../../../../services/category_service.dart'; // Import CategoryService

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
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = []; // Danh sách các danh mục
  List<String> _selectedCategories = []; // Danh sách các danh mục đã chọn

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Tải danh sách danh mục khi khởi tạo
  }

  // Tải danh sách danh mục từ Firestore
  Future<void> _loadCategories() async {
    final categories = await _categoryService.getCategories();
    setState(() {
      _categories = categories;
    });
  }

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
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bạn cần đăng nhập để đăng tiểu thuyết.')),
      );
      return;
    }

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn ít nhất một danh mục.')),
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
      uid: user.uid,
      categories: _selectedCategories, // Thêm danh sách danh mục đã chọn
    );

    await _firestoreService.addNovel(novel);

    // Chuyển đến màn hình quản lý tiểu thuyết
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
            // Dropdown để chọn danh mục
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Chọn danh mục'),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && !_selectedCategories.contains(value)) {
                  setState(() {
                    _selectedCategories.add(value);
                  });
                }
              },
            ),
            SizedBox(height: 10),
            // Hiển thị danh sách danh mục đã chọn
            Wrap(
              spacing: 8.0,
              children: _selectedCategories.map((categoryId) {
                final category = _categories.firstWhere(
                  (cat) => cat.id == categoryId,
                  orElse: () => Category(id: '', name: '', description: '', createdAt: DateTime.now()),
                );
                return Chip(
                  label: Text(category.name),
                  onDeleted: () {
                    setState(() {
                      _selectedCategories.remove(categoryId);
                    });
                  },
                );
              }).toList(),
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