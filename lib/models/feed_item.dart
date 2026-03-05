class FeedItem {
  final String id;
  final String userName;
  final String text;
  final String imageUrl;
  final int likes;
  final String category; // 'all', 'gentle', 'healing', 'food', 'travel'

  FeedItem({
    required this.id,
    required this.userName,
    required this.text,
    required this.imageUrl,
    this.likes = 0,
    this.category = 'all',
  });
}
