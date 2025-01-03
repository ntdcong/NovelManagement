class Chapter {
  final String id;
  final String title;
  final String content;

  Chapter({
    required this.id,
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
    );
  }
}
