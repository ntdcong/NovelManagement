import 'package:doc_quan_ly_tieu_thuyet/models/chapter.dart';

class Novel {
  final String id;
  final String title;
  final String author;
  final String uid;
  final int views;
  final String coverImage;
  final List<Chapter> chapters;
  final List<String> categories; // Thêm trường categories

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.uid,
    required this.views,
    required this.coverImage,
    required this.chapters,
    required this.categories, // Thêm vào constructor
  });

  // Chuyển đổi đối tượng Novel thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'uid': uid,
      'views': views,
      'coverImage': coverImage,
      'chapters': chapters.map((chapter) => chapter.toMap()).toList(),
      'categories': categories, // Thêm vào map
    };
  }

  // Chuyển đổi từ Map Firestore thành đối tượng Novel
  factory Novel.fromMap(Map<String, dynamic> data) {
    return Novel(
      id: data['id'] ?? '',
      title: data['title'] ?? 'Chưa có tên',
      author: data['author'] ?? 'Chưa có tác giả',
      views: data['views'] ?? 0,
      coverImage: data['coverImage'] ?? '',
      uid: data['uid'] ?? '',
      chapters: (data['chapters'] as List<dynamic>? ?? [])
          .map((chapterData) => Chapter.fromMap(chapterData))
          .toList(),
      categories: (data['categories'] as List<dynamic>? ?? [])
          .map((category) => category.toString())
          .toList(), // Thêm vào factory
    );
  }
}