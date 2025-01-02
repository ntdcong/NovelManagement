class Novel {
  final String id;
  final String title;
  final String author;
  final int views;
  final String coverImage;
  final List<Chapter> chapters;

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.views,
    required this.coverImage,
    required this.chapters,
  });
}

class Chapter {
  final String id;
  final String title;
  final String content;

  Chapter({
    required this.id,
    required this.title,
    required this.content,
  });
}
