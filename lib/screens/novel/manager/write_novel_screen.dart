import 'package:doc_quan_ly_tieu_thuyet/main.dart';
import 'package:doc_quan_ly_tieu_thuyet/screens/novel/read/novel_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../../models/novel.dart';
import '../../../models/chapter.dart';
import '../../../models/category.dart';
import '../../../services/firestore_service.dart';
import '../../../services/category_service.dart';
import 'chapter_input_screen.dart';
import 'manage_novels_page.dart';

class WriteNovelScreen extends StatefulWidget {
  @override
  _WriteNovelScreenState createState() => _WriteNovelScreenState();
}

class _WriteNovelScreenState extends State<WriteNovelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _coverImageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  final _firestoreService = FirestoreService();
  final _categoryService = CategoryService();

  List<Category> _categories = [];
  List<Category> _selectedCategories = [];
  List<Chapter> _chapters = [];
  bool _isLoading = false;
  String? _coverImageError;

  @override
  void initState() {
    super.initState();
    _preloadUserData();
    _loadCategories();
  }

  Future<void> _preloadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _authorController.text = user.displayName ?? '';
    }
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => _isLoading = true);
      _categories = await _categoryService.getCategories();
    } catch (_) {
      _showSnackbar('Không thể tải danh mục. Vui lòng thử lại sau.', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _validateCoverImage(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void _addChapter() async {
    if (_chapters.length >= 100) {
      _showSnackbar('Số lượng chương đã đạt giới hạn (100 chương).', Colors.red);
      return;
    }

    final newChapter = await Navigator.push<Chapter>(
      context,
      MaterialPageRoute(builder: (_) => ChapterInputScreen()),
    );

    if (newChapter != null) {
      setState(() => _chapters.add(newChapter));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

Future<void> _publishNovel() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackbar('Bạn cần đăng nhập để đăng tiểu thuyết.', Colors.red);
      return;
    }
    if (_selectedCategories.isEmpty) {
      _showSnackbar('Vui lòng chọn ít nhất một danh mục.', Colors.red);
      return;
    }
    if (_chapters.isEmpty) {
      _showSnackbar('Vui lòng thêm ít nhất một chương.', Colors.red);
      return;
    }
    if (_coverImageController.text.isNotEmpty &&
        !await _validateCoverImage(_coverImageController.text)) {
      setState(() => _coverImageError = 'URL ảnh không hợp lệ');
      return;
    }

    final confirm = await _showConfirmationDialog();
    if (confirm != true) return;

    try {
      setState(() => _isLoading = true);

      final novel = Novel(
        id: '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        views: 0,
        coverImage: _coverImageController.text.trim(),
        chapters: _chapters,
        uid: user.uid,
        categories: _selectedCategories.map((c) => c.name).toList(),
      );

      await _firestoreService.addNovel(novel);
      _showSnackbar('Đăng truyện thành công!', Colors.green);

      // Chuyển đến BottomNavScreen với tab quản lý truyện (index 2)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => BottomNavScreen(initialIndex: 2), // index 2 là tab Quản Lý Truyện
        ),
        (route) => false,
      );

    } catch (_) {
      _showSnackbar('Có lỗi xảy ra khi đăng truyện. Vui lòng thử lại.', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
}

  Future<bool?> _showConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng truyện'),
        content: const Text('Bạn có chắc chắn muốn đăng truyện này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Đăng truyện')),
        ],
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Viết Tiểu Thuyết'),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => _showHelpDialog(),
        ),
      ],
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: _buildForm(), // Phần form nhập liệu
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, // Chiều rộng bằng với parent
                  child: ElevatedButton.icon(
                    onPressed: _publishNovel,
                    icon: const Icon(Icons.upload),
                    label: const Text('Đăng Truyện'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
  );
}

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBasicInfoCard(),
            const SizedBox(height: 16),
            _buildCoverImageAndCategoryCard(),
            const SizedBox(height: 16),
            _buildChapterListCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildCard(
      title: 'Thông tin cơ bản',
      children: [
        _buildTextFormField(_titleController, 'Tiêu đề *', Icons.book, 'Vui lòng nhập tiêu đề'),
        _buildTextFormField(_authorController, 'Tác giả *', Icons.person, 'Vui lòng nhập tên tác giả'),
        _buildTextFormField(_descriptionController, 'Mô tả', Icons.description, null, maxLines: 3),
      ],
    );
  }

  Widget _buildCoverImageAndCategoryCard() {
    return _buildCard(
      title: 'Ảnh bìa & Danh mục',
      children: [
        TextFormField(
          controller: _coverImageController,
          decoration: InputDecoration(
            labelText: 'URL ảnh bìa',
            prefixIcon: const Icon(Icons.image),
            border: const OutlineInputBorder(),
            errorText: _coverImageError,
          ),
          onChanged: (_) => setState(() => _coverImageError = null),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<Category>(
          decoration: const InputDecoration(
            labelText: 'Chọn danh mục *',
            prefixIcon: Icon(Icons.category),
            border: OutlineInputBorder(),
          ),
          items: _categories
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null && !_selectedCategories.contains(value)) {
              setState(() => _selectedCategories.add(value));
            }
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _selectedCategories.map((category) {
            return Chip(
              label: Text(category.name),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => setState(() => _selectedCategories.remove(category)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChapterListCard() {
    return _buildCard(
      title: 'Danh sách chương (${_chapters.length})',
      actions: [
        ElevatedButton.icon(
          onPressed: _addChapter,
          icon: const Icon(Icons.add),
          label: const Text('Thêm chương'),
        ),
      ],
      children: [
        if (_chapters.isNotEmpty)
          ListView.separated(
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: _chapters.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(_chapters[index].title),
                subtitle: Text('Nội dung chương ${index + 1}'),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    List<Widget>? children,
    List<Widget>? actions,
  }) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (actions != null) ...actions,
              ],
            ),
            const Divider(),
            if (children != null) ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? errorText, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        validator: (value) {
          if (errorText != null && (value == null || value.trim().isEmpty)) {
            return errorText;
          }
          return null;
        },
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hướng dẫn sử dụng'),
        content: const Text('Đây là công cụ để viết và quản lý tiểu thuyết của bạn.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
