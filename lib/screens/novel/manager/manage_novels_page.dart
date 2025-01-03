import 'package:doc_quan_ly_tieu_thuyet/widgets/category_selection_dialog.dart';
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

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteNovel(String novelId) async {
    if (novelId.isEmpty) {
      _showSnackbar('ID truyện không hợp lệ');
      return;
    }

    bool confirmDelete = await _showConfirmDialog('Xác nhận xóa truyện?', 'Bạn có chắc chắn muốn xóa truyện này?');
    if (!confirmDelete) return;

    try {
      await firestore.collection('novels').doc(novelId).delete();
      _showSnackbar('Xóa truyện thành công');
    } catch (e) {
      _showSnackbar('Lỗi khi xóa truyện: $e');
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    bool? result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _updateNovelDetails(Novel novel, Map<String, dynamic> data) async {
    try {
      await firestore.collection('novels').doc(novel.id).update(data);
      _showSnackbar('Cập nhật thông tin thành công');
    } catch (e) {
      _showSnackbar('Lỗi khi cập nhật thông tin: $e');
    }
  }

  Future<void> _showAddChapterDialog(Novel novel) async {
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
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tiêu đề chương')),
              const SizedBox(height: 16),
              TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Nội dung'), maxLines: 5),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty || contentController.text.isEmpty) {
                _showSnackbar('Vui lòng điền đầy đủ thông tin');
                return;
              }

              try {
                final newChapter = Chapter(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  content: contentController.text,
                );
                final updatedChapters = [...novel.chapters, newChapter];
                await firestore.collection('novels').doc(novel.id).update({'chapters': updatedChapters.map((c) => c.toMap()).toList()});
                Navigator.pop(context);
                _showSnackbar('Thêm chương mới thành công');
              } catch (e) {
                _showSnackbar('Lỗi khi thêm chương mới: $e');
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditNovelDialog(Novel novel) async {
    final titleController = TextEditingController(text: novel.title);
    final authorController = TextEditingController(text: novel.author);
    final coverImageController = TextEditingController(text: novel.coverImage);
    final selectedCategories = Set<String>.from(novel.categories);

    // Lấy danh sách danh mục từ Firestore
    final snapshot = await firestore.collection('categories').get();
    final allCategories = snapshot.docs.map((doc) => doc['name'].toString()).toList();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Cập nhật thông tin truyện'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tiêu đề')),
                    TextField(controller: authorController, decoration: const InputDecoration(labelText: 'Tác giả')),
                    TextField(controller: coverImageController, decoration: const InputDecoration(labelText: 'Link ảnh bìa')),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await showDialog<Set<String>>(
                          context: context,
                          builder: (context) => CategorySelectionDialog(
                            allCategories: allCategories,
                            selectedCategories: selectedCategories,
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            selectedCategories.clear();
                            selectedCategories.addAll(result);
                          });
                        }
                      },
                      child: const Text('Chọn danh mục'),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: selectedCategories.map((category) {
                        return Chip(
                          label: Text(category),
                          onDeleted: () {
                            setState(() {
                              selectedCategories.remove(category);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isEmpty || authorController.text.isEmpty) {
                      _showSnackbar('Vui lòng điền đầy đủ thông tin');
                      return;
                    }
                    _updateNovelDetails(novel, {
                      'title': titleController.text,
                      'author': authorController.text,
                      'coverImage': coverImageController.text,
                      'categories': selectedCategories.toList(),
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Cập nhật'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập để xem danh sách truyện của bạn')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý truyện')),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('novels').where('uid', isEqualTo: currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final novels = snapshot.data?.docs.map((doc) => Novel.fromMap({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })).toList() ?? [];

          if (novels.isEmpty) return const Center(child: Text('Bạn chưa có truyện nào'));

          return ListView.builder(
            itemCount: novels.length,
            itemBuilder: (context, index) {
              final novel = novels[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: novel.coverImage.isNotEmpty
                      ? Image.network(novel.coverImage, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.book))
                      : const Icon(Icons.book),
                  title: Text(novel.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tác giả: ${novel.author}'),
                      Wrap(
                        spacing: 8.0,
                        children: novel.categories.map((category) => Chip(label: Text(category))).toList(),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditNovelDialog(novel);
                          break;
                        case 'add_chapter':
                          _showAddChapterDialog(novel);
                          break;
                        case 'delete':
                          _deleteNovel(novel.id);
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                        const PopupMenuItem(value: 'add_chapter', child: Text('Thêm chương')),
                        const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                      ];
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