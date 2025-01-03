import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doc_quan_ly_tieu_thuyet/models/novel.dart';
import 'package:doc_quan_ly_tieu_thuyet/models/chapter.dart';

class ManageNovelsPage extends StatefulWidget {
  const ManageNovelsPage({Key? key}) : super(key: key);

  @override
  State<ManageNovelsPage> createState() => _ManageNovelsPageState();
}

class _ManageNovelsPageState extends State<ManageNovelsPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  Future<void> _deleteNovel(String novelId) async {
    if (novelId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID truyện không hợp lệ')),
      );
      return;
    }

    try {
      await firestore.collection('novels').doc(novelId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa truyện thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa truyện: $e')),
      );
    }
  }

  void _showAddChapterDialog(Novel novel) {
    if (novel.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID truyện không hợp lệ')),
      );
      return;
    }

    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm chương mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề chương'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Nội dung'),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty || contentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                );
                return;
              }

              try {
                final newChapter = Chapter(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  content: contentController.text,
                );

                final updatedChapters = [...novel.chapters, newChapter];
                await firestore.collection('novels').doc(novel.id).update({
                  'chapters': updatedChapters.map((c) => c.toMap()).toList(),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thêm chương mới thành công')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi thêm chương mới: $e')),
                );
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditNovelDialog(Novel novel) {
    if (novel.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID truyện không hợp lệ')),
      );
      return;
    }

    final titleController = TextEditingController(text: novel.title);
    final authorController = TextEditingController(text: novel.author);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật thông tin truyện'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Tác giả'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty || authorController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                );
                return;
              }

              try {
                await firestore.collection('novels').doc(novel.id).update({
                  'title': titleController.text,
                  'author': authorController.text,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật thông tin thành công')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi cập nhật thông tin: $e')),
                );
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Vui lòng đăng nhập để xem danh sách truyện của bạn'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý truyện'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('novels')
            .where('uid', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final novels = snapshot.data?.docs
              .map((doc) => Novel.fromMap({
                    ...doc.data() as Map<String, dynamic>,
                    'id': doc.id, // Đảm bảo ID được gán chính xác
                  }))
              .toList() ??
              [];

          if (novels.isEmpty) {
            return const Center(child: Text('Bạn chưa có truyện nào'));
          }

          return ListView.builder(
            itemCount: novels.length,
            itemBuilder: (context, index) {
              final novel = novels[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: novel.coverImage.isNotEmpty
                      ? Image.network(
                          novel.coverImage,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.book),
                        )
                      : const Icon(Icons.book),
                  title: Text(novel.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tác giả: ${novel.author}'),
                      Text('Số chương: ${novel.chapters.length}'),
                      Text('Lượt xem: ${novel.views}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'add_chapter',
                        child: Text('Thêm chương'),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Sửa thông tin'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Xóa truyện'),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'add_chapter':
                          _showAddChapterDialog(novel);
                          break;
                        case 'edit':
                          _showEditNovelDialog(novel);
                          break;
                        case 'delete':
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xác nhận xóa'),
                              content: const Text(
                                  'Bạn có chắc chắn muốn xóa truyện này?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteNovel(novel.id);
                                  },
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                          break;
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}