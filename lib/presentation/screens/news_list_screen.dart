import 'package:flutter/material.dart';

import '../../data/models/app_user.dart';
import '../../data/models/news_item.dart';
import '../../data/repositories/school_repository.dart';
import '../widgets/async_list.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({
    super.key,
    required this.repository,
    required this.user,
  });

  final SchoolRepository repository;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return AsyncList<NewsItem>(
      stream: repository.watchNews,
      emptyMessage: user.isAdmin
          ? 'No news yet.\nTap "Post news" to publish the first one.'
          : 'No news yet.\nCheck back soon.',
      itemBuilder: (context, item) => NewsCard(
        item: item,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => NewsDetailScreen(
              item: item,
              repository: repository,
              user: user,
            ),
          ),
        ),
      ),
    );
  }
}
