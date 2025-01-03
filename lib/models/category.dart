// models/category.dart
class Category {
  final String? id; // ID của danh mục (tự động tạo bởi Firestore)
  final String name; // Tên danh mục
  final String description; // Mô tả danh mục
  final DateTime createdAt; // Ngày tạo

  Category({
    this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  // Chuyển đổi từ Map sang Category
  factory Category.fromMap(Map<String, dynamic> data, String id) {
    return Category(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  // Chuyển đổi từ Category sang Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}