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

  // Thêm tiểu thuyết mới
  Future<void> addNovel(Novel novel) async {
    try {
      final novelData = novel.toMap();
      await _firestore.collection('novels').add(novelData);
    } catch (error) {
      print("Lỗi khi thêm tiểu thuyết: $error");
    }
  }

  // Cập nhật thông tin tiểu thuyết
  Future<void> updateNovel(Novel novel) async {
    try {
      if (novel.id.isEmpty) {
        throw Exception('ID tiểu thuyết không hợp lệ');
      }

      await _firestore.collection('novels').doc(novel.id).update(novel.toMap());
    } catch (e) {
      print('Lỗi khi cập nhật tiểu thuyết: $e');
      rethrow;
    }
  }

  // Lấy tất cả tiểu thuyết
  Future<List<Novel>> getNovels() async {
    try {
      final snapshot = await _firestore.collection('novels').get();
      return snapshot.docs.map((doc) {
        final novelData = doc.data();
        novelData['id'] = doc.id; // Thêm id vào dữ liệu
        return Novel.fromMap(novelData);
      }).toList();
    } catch (error) {
      print("Lỗi khi lấy danh sách tiểu thuyết: $error");
      return [];
    }
  }

  // Lấy tiểu thuyết theo ID
  Future<Novel?> getNovelById(String novelId) async {
    try {
      final doc = await _firestore.collection('novels').doc(novelId).get();
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      data['id'] = doc.id;
      return Novel.fromMap(data);
    } catch (e) {
      print('Lỗi khi lấy tiểu thuyết: $e');
      return null;
    }
  }

  // Xóa tiểu thuyết
  Future<void> removeNovel(String novelId) async {
    try {
      if (novelId.isEmpty) {
        throw Exception('ID tiểu thuyết không hợp lệ');
      }

      await _firestore.collection('novels').doc(novelId).delete();
      print('Xóa thành công');
    } catch (e) {
      print('Lỗi khi xóa tiểu thuyết: $e');
      rethrow;
    }
  }

  // Lấy danh sách yêu thích của user
  Future<List<Favorite>> getUserFavorites(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Thêm id nếu cần
        return Favorite.fromJson(data);
      }).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách yêu thích: $e');
      return [];
    }
  }

  Future<List<Novel>> getFavoriteNovels(String userId) async {
    try {
      final favoriteSnapshots = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      final novels = <Novel>[];
      for (var doc in favoriteSnapshots.docs) {
        final favorite = Favorite.fromJson(doc.data());
        final novel = await getNovelById(favorite.novelId);
        if (novel != null) {
          novels.add(novel);
        }
      }
      return novels;
    } catch (e) {
      print('Lỗi khi lấy danh sách tiểu thuyết yêu thích: $e');
      return [];
    }
  }
}
