import 'package:flutter/material.dart';

import '../../data/models/news_item.dart';
import '../../data/repositories/school_repository.dart';
import '../widgets/async_list.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key, required this.repository});

  final SchoolRepository repository;

  @override
  Widget build(BuildContext context) {
    return AsyncList<NewsItem>(
      load: repository.fetchNews,
      emptyMessage: 'No news yet.\nCheck back soon.',
      itemBuilder: (context, item) => NewsCard(
        item: item,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NewsDetailScreen(item: item)),
        ),
      ),
    );
  }
}
