import 'package:flutter/material.dart';
import '../models/novel.dart';
import 'chapter_detail_screen.dart';

class NovelDetailScreen extends StatelessWidget {
  final Novel novel;

  const NovelDetailScreen({
    Key? key,
    required this.novel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoverImage(),
              const SizedBox(height: 16),
              _buildNovelInfo(),
              const SizedBox(height: 16),
              _buildChaptersList(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(novel.title),
      elevation: 0,
    );
  }

  Widget _buildCoverImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        novel.coverImage,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 300,
            color: Colors.grey[300],
            child: const Icon(Icons.error_outline, size: 50),
          );
        },
      ),
    );
  }

  Widget _buildNovelInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          novel.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tác giả: ${novel.author}',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.remove_red_eye, size: 16),
            const SizedBox(width: 4),
            Text(
              '${novel.views} lượt xem',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChaptersList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh sách các chương',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: novel.chapters.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final chapter = novel.chapters[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(
                chapter.title,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigateToChapter(context, chapter, index),
            );
          },
        ),
      ],
    );
  }

  void _navigateToChapter(BuildContext context, dynamic chapter, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterDetailScreen(
          chapter: chapter,
          chapterIndex: index,
          chapters: novel.chapters,
        ),
      ),
    );
  }
}