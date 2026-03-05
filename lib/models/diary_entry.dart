class DiaryEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String mood;
  final String? imageUrl;

  DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'mood': mood,
      'imageUrl': imageUrl,
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: json['mood'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
