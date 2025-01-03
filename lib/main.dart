import 'package:doc_quan_ly_tieu_thuyet/screens/auth/auth_screen.dart';
import 'package:doc_quan_ly_tieu_thuyet/screens/novel/manager/favorite_novels_screen.dart';
import 'package:doc_quan_ly_tieu_thuyet/screens/novel/manager/manage_novels_page.dart';
import 'package:doc_quan_ly_tieu_thuyet/screens/novel/read/novel_list_screen.dart';
import 'package:doc_quan_ly_tieu_thuyet/screens/auth/profile_screen.dart'; // Màn hình hồ sơ// Màn hình yêu thích
import 'package:doc_quan_ly_tieu_thuyet/screens/novel/manager/write_novel_screen.dart';
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
          return const Center(child: CircularProgressIndicator());
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
  final int initialIndex;

  const BottomNavScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  late int _selectedIndex;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Danh sách các màn hình của ứng dụng
  final List<Widget> _screens = [
    NovelListScreen(),
    WriteNovelScreen(),
    const ManageNovelsPage(),
    FavoriteNovelsScreen(userId: FirebaseAuth.instance.currentUser!.uid),
    ProfileScreen(),
  ];

  // Hiển thị hộp thoại xác nhận đăng xuất
  Future<void> _confirmLogout() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _logout(); // Thực hiện đăng xuất
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: const Text('Đồng ý',
                  style: TextStyle(color: Colors.deepPurple)),
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
      MaterialPageRoute(
          builder: (context) => AuthScreen()), // Chuyển về màn hình đăng nhập
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
        title: const Text(
          'NOVEL CTH',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white, // Chữ màu trắng
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app,
                color: Colors.white), // Icon màu trắng
            onPressed: _confirmLogout, // Hiển thị hộp thoại xác nhận đăng xuất
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300), // Thời gian chuyển đổi
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
              offset: const Offset(0, -5),
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
          type:
              BottomNavigationBarType.fixed, // Cố định chiều cao của BottomNav
          selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold), // Nhãn được chọn in đậm
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Tiểu Thuyết',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.publish_rounded),
              label: 'Viết Truyện',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Quản Lý Truyện',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Yêu Thích',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Hồ Sơ',
            ),
          ],
        ),
      ),
    );
  }
}
