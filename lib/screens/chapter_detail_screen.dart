import 'package:flutter/material.dart';
import '../models/novel.dart';

class ChapterDetailScreen extends StatefulWidget {
  final Chapter chapter;
  final int chapterIndex;
  final List<Chapter> chapters;

  const ChapterDetailScreen({
    Key? key,
    required this.chapter,
    required this.chapterIndex,
    required this.chapters,
  }) : super(key: key);

  @override
  _ChapterDetailScreenState createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  double _fontSize = 16.0;
  ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  void _navigateToChapter(int index) {
    if (index >= 0 && index < widget.chapters.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChapterDetailScreen(
            chapter: widget.chapters[index],
            chapterIndex: index,
            chapters: widget.chapters,
          ),
        ),
      );
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Cài đặt hiển thị'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Kích thước chữ'),
                  Slider(
                    value: _fontSize,
                    min: 12.0,
                    max: 32.0,
                    divisions: 10,
                    label: _fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        this.setState(() {
                          _fontSize = value;
                        });
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Đóng'),
                  onPressed: () => Navigator.of(context).pop(),
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Chương ${widget.chapterIndex + 1}',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Danh sách chương',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.chapters.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      selected: index == widget.chapterIndex,
                      title: Text(
                        'Chương ${index + 1}: ${widget.chapters[index].title}',
                        style: TextStyle(
                          color: index == widget.chapterIndex 
                            ? Theme.of(context).primaryColor 
                            : null,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToChapter(index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chapter.title,
                    style: TextStyle(
                      fontSize: _fontSize + 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.chapter.content,
                    style: TextStyle(
                      fontSize: _fontSize,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: widget.chapterIndex > 0
                        ? () => _navigateToChapter(widget.chapterIndex - 1)
                        : null,
                  ),
                  Text(
                    '${widget.chapterIndex + 1}/${widget.chapters.length}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: widget.chapterIndex < widget.chapters.length - 1
                        ? () => _navigateToChapter(widget.chapterIndex + 1)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}