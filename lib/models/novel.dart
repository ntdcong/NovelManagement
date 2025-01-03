import 'package:cloud_firestore/cloud_firestore.dart';
import 'chapter.dart';

class Novel {
  final String id;
  final String title;
  final String author;
  final String uid;
  final int views;
  final String coverImage;
  final List<Chapter> chapters;

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.uid,
    required this.views,
    required this.coverImage,
    required this.chapters,
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
    );
  }
}
