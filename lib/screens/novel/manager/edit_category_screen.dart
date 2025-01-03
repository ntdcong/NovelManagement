// screens/novel/read/edit_category_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../models/novel.dart';
import '../../../../../models/category.dart';
import '../../../../../services/category_service.dart';

class EditCategoryScreen extends StatefulWidget {
  final Novel novel;

  EditCategoryScreen({required this.novel});

  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final CategoryService _categoryService = CategoryService();
  List<Category> _allCategories = [];
  List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _selectedCategories = widget.novel.categories;
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryService.getCategories();
    setState(() {
      _allCategories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa danh mục'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('novels')
                  .doc(widget.novel.id)
                  .update({'categories': _selectedCategories});
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            'Chọn danh mục:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ..._allCategories.map((category) {
            return CheckboxListTile(
              title: Text(category.name),
              value: _selectedCategories.contains(category.id),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedCategories.add(category.id!);
                  } else {
                    _selectedCategories.remove(category.id);
                  }
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}