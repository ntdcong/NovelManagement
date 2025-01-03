class Favorite {
  final String novelId;
  final String userId;
  final DateTime addedDate;

  Favorite({
    required this.novelId,
    required this.userId,
    required this.addedDate,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      novelId: json['novelId'],
      userId: json['userId'],
      addedDate: DateTime.parse(json['addedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      
      'novelId': novelId,
      'userId': userId,
      'addedDate': addedDate.toIso8601String(),
    };
  }
}
