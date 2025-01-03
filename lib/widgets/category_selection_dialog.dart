import 'package:flutter/material.dart';

class CategorySelectionDialog extends StatefulWidget {
  final List<String> allCategories; // Danh sách tất cả các danh mục
  final Set<String> selectedCategories; // Danh sách các danh mục đã chọn

  const CategorySelectionDialog({
    Key? key,
    required this.allCategories,
    required this.selectedCategories,
  }) : super(key: key);

  @override
  _CategorySelectionDialogState createState() => _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<CategorySelectionDialog> {
  late Set<String> _selectedCategories; // Danh sách các danh mục đã chọn (trạng thái cục bộ)

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách các danh mục đã chọn từ widget cha
    _selectedCategories = Set.from(widget.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn danh mục'), // Tiêu đề của dialog
      content: SingleChildScrollView(
        child: Column(
          children: widget.allCategories.map((category) {
            return CheckboxListTile(
              title: Text(category), // Hiển thị tên danh mục
              value: _selectedCategories.contains(category), // Kiểm tra xem danh mục đã được chọn chưa
              onChanged: (value) {
                setState(() {
                  // Cập nhật danh sách các danh mục đã chọn
                  if (value == true) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        // Nút hủy
        TextButton(
          onPressed: () => Navigator.pop(context), // Đóng dialog mà không trả về kết quả
          child: const Text('Hủy'),
        ),
        // Nút xác nhận
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedCategories), // Trả về danh sách các danh mục đã chọn
          child: const Text('Xong'),
        ),
      ],
    );
  }
}