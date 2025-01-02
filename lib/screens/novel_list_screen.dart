import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/novel.dart';
import 'novel_detail_screen.dart';

class NovelListScreen extends StatefulWidget {
  @override
  _NovelListScreenState createState() => _NovelListScreenState();
}

class _NovelListScreenState extends State<NovelListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Novel>> fetchNovels() async {
    final snapshot = await _firestore.collection('novels').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Novel(
        id: doc.id,
        title: data['title'] ?? '',
        author: data['author'] ?? '',
        views: data['views'] ?? 0,
        coverImage: data['coverImage'] ?? '',
        chapters: (data['chapters'] as List<dynamic>?)
                ?.map((chapter) => Chapter(
                      id: chapter['id'] ?? '',
                      title: chapter['title'] ?? '',
                      content: chapter['content'] ?? '',
                    ))
                .toList() ??
            [],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Tiểu Thuyết'),     
      ),
      body: FutureBuilder<List<Novel>>(
        future: fetchNovels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Chưa có tiểu thuyết nào.'));
          }

          final novels = snapshot.data!;
          return ListView.builder(
            itemCount: novels.length,
            itemBuilder: (context, index) {
              final novel = novels[index];
              return ListTile(
                leading: Image.network(
                  novel.coverImage,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(novel.title),
                subtitle: Text('Lượt đọc: ${novel.views}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NovelDetailScreen(novel: novel),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
