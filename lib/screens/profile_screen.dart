import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Đặt tên alias
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance; // Sử dụng alias
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Tải thông tin người dùng từ Firestore
  Future<void> _loadUserData() async {
    firebase_auth.User? currentUser = _auth.currentUser; // Sử dụng alias
    if (currentUser != null) {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        setState(() {
          _user = User.fromMap(userDoc.data()!);
        });
      }
    }
  }

  // Hàm cập nhật thông tin người dùng
  Future<void> _updateUserInfo(String name, String email, String avatarUrl) async {
    firebase_auth.User? currentUser = _auth.currentUser; // Sử dụng alias
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
      });
      setState(() {
        _user = User(
          id: currentUser.uid,
          name: name,
          email: email,
          avatarUrl: avatarUrl,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Hồ Sơ')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Hồ Sơ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(_user!.avatarUrl),
            ),
            SizedBox(height: 16),
            Text('Tên: ${_user!.name}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Email: ${_user!.email}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showEditDialog(context),
              child: Text('Chỉnh sửa thông tin'),
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị hộp thoại để chỉnh sửa thông tin người dùng
  void _showEditDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: _user!.name);
    TextEditingController emailController = TextEditingController(text: _user!.email);
    TextEditingController avatarUrlController = TextEditingController(text: _user!.avatarUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chỉnh sửa thông tin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Tên'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: avatarUrlController,
                decoration: InputDecoration(labelText: 'Ảnh đại diện (URL)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                _updateUserInfo(
                  nameController.text,
                  emailController.text,
                  avatarUrlController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }
}