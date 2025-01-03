// screens/category_list_screen.dart
import 'package:doc_quan_ly_tieu_thuyet/screens/add_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:doc_quan_ly_tieu_thuyet/services/category_service.dart';
import 'package:doc_quan_ly_tieu_thuyet/models/category.dart';

class CategoryListScreen extends StatelessWidget {
  final CategoryService _categoryService = CategoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách danh mục'),
      ),
      body: FutureBuilder<List<Category>>(
        future: _categoryService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có danh mục nào.'));
          }

          final categories = snapshot.data!;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category.name),
                subtitle: Text(category.description),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _categoryService.deleteCategory(category.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã xóa danh mục')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Điều hướng đến trang thêm danh mục
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCategoryScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}