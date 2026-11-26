enum NewsCategory { announcement, academics, sports, clubs }

class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.category,
    required this.publishedAt,
  });

  final String id;
  final String title;
  final String summary;
  final String body;
  final NewsCategory category;
  final DateTime publishedAt;
}
