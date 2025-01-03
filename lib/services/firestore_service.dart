import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doc_quan_ly_tieu_thuyet/models/novel.dart';
import 'package:doc_quan_ly_tieu_thuyet/models/favorite.dart';
import 'package:doc_quan_ly_tieu_thuyet/models/chapter.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Thêm yêu thích
  Future<void> addFavorite(String userId, String novelId) async {
    final favorite = Favorite(
      novelId: novelId,
      userId: userId,
      addedDate: DateTime.now(),
    );

    try {
      await _firestore.collection('favorites').add(favorite.toJson());
    } catch (error) {
      print("Lỗi khi thêm yêu thích: $error");
    }
  }

  // Thêm tiểu thuyết mới
  Future<void> addNovel(Novel novel) async {
    try {
      final novelData = {
        'title': novel.title,
        'author': novel.author,
        'views': novel.views,
        'coverImage': novel.coverImage,
        'uid': novel.uid, // Thêm trường uid
        'chapters': novel.chapters
            .map((chapter) => {
                  'id': chapter.id,
                  'title': chapter.title,
                  'content': chapter.content,
                })
            .toList(),
      };

      await _firestore.collection('novels').add(novelData);
    } catch (error) {
      print("Lỗi khi thêm tiểu thuyết: $error");
    }
  }

  // Cập nhật thông tin tiểu thuyết
  Future<void> updateNovel(Novel novel) async {
    try {
      // Kiểm tra xem ID có hợp lệ không
      if (novel.id == null || novel.id!.isEmpty) {
        throw Exception('ID tiểu thuyết không hợp lệ');
      }

      // Cập nhật tài liệu trong Firestore
      await _firestore.collection('novels').doc(novel.id).update({
        'title': novel.title,
        'author': novel.author,
        'coverImage': novel.coverImage,
        'views': novel.views,
        'chapters': novel.chapters
            .map((chapter) => {
                  'id': chapter.id,
                  'title': chapter.title,
                  'content': chapter.content,
                })
            .toList(),
      });

      print('Cập nhật thành công');
    } catch (e) {
      print('Lỗi khi cập nhật tiểu thuyết: $e');
      rethrow; // Để có thể bắt lỗi ở nơi gọi phương thức
    }
  }

  // Lấy tất cả tiểu thuyết
  Future<List<Novel>> getNovels() async {
    try {
      final snapshot = await _firestore.collection('novels').get();
      return snapshot.docs.map((doc) {
        final novelData = doc.data();
        final chapters = (novelData['chapters'] as List)
            .map((chapter) => Chapter(
                  id: chapter['id'],
                  title: chapter['title'],
                  content: chapter['content'],
                ))
            .toList();

        return Novel(
          id: doc.id,
          title: novelData['title'],
          author: novelData['author'],
          views: novelData['views'],
          coverImage: novelData['coverImage'],
          chapters: chapters,
          uid: novelData['uid'], // Đọc uid từ Firestore
        );
      }).toList();
    } catch (error) {
      print("Lỗi khi lấy tiểu thuyết: $error");
      return [];
    }
  }

  // Lấy tiểu thuyết theo ID
  Future<Novel?> getNovelById(String novelId) async {
    try {
      final doc = await _firestore.collection('novels').doc(novelId).get();

      if (doc.exists) {
        final novelData = doc.data();
        final chapters = (novelData!['chapters'] as List)
            .map((chapter) => Chapter(
                  id: chapter['id'],
                  title: chapter['title'],
                  content: chapter['content'],
                ))
            .toList();

        return Novel(
          id: doc.id,
          title: novelData['title'],
          author: novelData['author'],
          views: novelData['views'],
          coverImage: novelData['coverImage'],
          uid: novelData['uid'], // Đọc uid từ Firestore
          chapters: chapters,
        );
      } else {
        return null;
      }
    } catch (error) {
      print("Lỗi khi lấy tiểu thuyết: $error");
      return null;
    }
  }

  // Xóa tiểu thuyết
  Future<void> removeNovel(String novelId) async {
  if (novelId == null || novelId.isEmpty) {
    throw Exception('ID tiểu thuyết không hợp lệ');
  }
  try {
    await _firestore.collection('novels').doc(novelId).delete();
    print('Xóa thành công');
  } catch (e) {
    print('Lỗi khi xóa tiểu thuyết: $e');
    rethrow;
  }
}


  // Xóa yêu thích
  Future<void> removeFavorite(String userId, String novelId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('novelId', isEqualTo: novelId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (error) {
      print("Lỗi khi xóa yêu thích: $error");
    }
  }

  // Lấy danh sách yêu thích của người dùng
  Future<List<Favorite>> getUserFavorites(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => Favorite.fromJson(doc.data())).toList();
    } catch (error) {
      print("Lỗi khi lấy danh sách yêu thích: $error");
      return [];
    }
  }
}
