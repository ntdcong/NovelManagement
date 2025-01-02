import 'package:doc_quan_ly_tieu_thuyet/screens/auth_screen.dart';
import 'package:doc_quan_ly_tieu_thuyet/screens/novel_list_screen.dart';
import 'package:doc_quan_ly_tieu_thuyet/screens/profile_screen.dart'; // Màn hình hồ sơ
import 'package:doc_quan_ly_tieu_thuyet/screens/favorite_screen.dart'; // Màn hình yêu thích
import 'package:doc_quan_ly_tieu_thuyet/screens/write_novel_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Thêm FirebaseAuth
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đọc - Quản Lý Tiểu Thuyết',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // Chỉnh màu sắc tổng thể
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthCheck(), // Kiểm tra xem người dùng đã đăng nhập chưa
    );
  }
}

class AuthCheck extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(), // Kiểm tra trạng thái đăng nhập
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return BottomNavScreen(); // Nếu đã đăng nhập, chuyển đến màn hình chính
        } else {
          return AuthScreen(); // Nếu chưa đăng nhập, hiển thị màn hình đăng nhập
        }
      },
    );
  }
}

class BottomNavScreen extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Danh sách các màn hình của ứng dụng
  final List<Widget> _screens = [
    NovelListScreen(),
    ProfileScreen(),
    FavoriteScreen(userId: '',),
    WriteNovelScreen(),
  ];

  // Thực hiện đăng xuất
  Future<void> _logout() async {
    await _auth.signOut(); // Đăng xuất Firebase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()), // Chuyển về màn hình đăng nhập
    );
  }

  // Chuyển đổi màn hình khi người dùng chọn tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4, // Thêm độ nổi cho app bar
        backgroundColor: Colors.deepPurple, // Màu AppBar đẹp hơn
        title: Text(
          'NOVEL CTH',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24), // Cải thiện font chữ
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout, // Đăng xuất khi nhấn nút
          ),
        ],
      ),
      body: _screens[_selectedIndex], // Hiển thị màn hình đã chọn
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepPurple[50], // Màu nền BottomNav
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple, // Màu của tab đang được chọn
        unselectedItemColor: Colors.grey, // Màu của các tab chưa được chọn
        showUnselectedLabels: false, // Ẩn nhãn khi không chọn
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Tiểu Thuyết',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Hồ Sơ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Yêu Thích',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.publish_rounded),
            label: 'Viết Truyện',
          ),
        ],
      ),
    );
  }
}
