// services/category_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doc_quan_ly_tieu_thuyet/models/category.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Thêm danh mục mới
  Future<void> addCategory(Category category) async {
    try {
      await _firestore.collection('categories').add(category.toMap());
    } catch (e) {
      print('Lỗi khi thêm danh mục: $e');
      rethrow;
    }
  }

  // Lấy danh sách tất cả danh mục
  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs.map((doc) {
        return Category.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách danh mục: $e');
      return [];
    }
  }

  // Lấy danh mục theo ID
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore.collection('categories').doc(categoryId).get();
      if (!doc.exists) return null;
      return Category.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('Lỗi khi lấy danh mục: $e');
      return null;
    }
  }

  // Cập nhật danh mục
  Future<void> updateCategory(Category category) async {
    try {
      if (category.id == null) {
        throw Exception('ID danh mục không hợp lệ');
      }
      await _firestore.collection('categories').doc(category.id).update(category.toMap());
    } catch (e) {
      print('Lỗi khi cập nhật danh mục: $e');
      rethrow;
    }
  }

  // Xóa danh mục
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
    } catch (e) {
      print('Lỗi khi xóa danh mục: $e');
      rethrow;
    }
  }
}