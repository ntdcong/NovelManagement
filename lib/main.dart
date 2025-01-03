import 'package:doc_quan_ly_tieu_thuyet/screens/auth_screen.dart';
import 'package:doc_quan_ly_tieu_thuyet/screens/manage_novels_page.dart';
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
    FavoriteScreen(userId: ''),
    WriteNovelScreen(),
    ManageNovelsPage(),
  ];

  // Hiển thị hộp thoại xác nhận đăng xuất
  Future<void> _confirmLogout() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xác nhận đăng xuất'),
          content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _logout(); // Thực hiện đăng xuất
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text('Đồng ý', style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );
  }

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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white, // Chữ màu trắng
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white), // Icon màu trắng
            onPressed: _confirmLogout, // Hiển thị hộp thoại xác nhận đăng xuất
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300), // Thời gian chuyển đổi
        child: _screens[_selectedIndex],
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white, // Màu nền BottomNav
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.deepPurple, // Màu của tab đang được chọn
          unselectedItemColor: Colors.grey, // Màu của các tab chưa được chọn
          showUnselectedLabels: true, // Hiển thị nhãn cho tất cả các tab
          type: BottomNavigationBarType.fixed, // Cố định chiều cao của BottomNav
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold), // Nhãn được chọn in đậm
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
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Quản Lý Truyện',
            ),
          ],
        ),
      ),
    );
  }
}