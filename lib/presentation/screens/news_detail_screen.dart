import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../data/models/app_user.dart';
import '../../data/models/news_item.dart';
import '../../data/repositories/school_repository.dart';
import '../widgets/category_style.dart';
import '../widgets/dialogs.dart';
import 'news_form_screen.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({
    super.key,
    required this.item,
    required this.repository,
    required this.user,
  });

  final NewsItem item;
  final SchoolRepository repository;
  final AppUser user;

  Future<void> _edit(BuildContext context) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => NewsFormScreen(repository: repository, existing: item),
      ),
    );
    if (saved == true && context.mounted) Navigator.of(context).pop();
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await confirmDelete(context, title: 'Delete this news post?');
    if (!ok) return;
    try {
      await repository.deleteNews(item.id);
      if (context.mounted) Navigator.of(context).pop();
    } catch (_) {
      if (context.mounted) {
        showMessage(context, "Couldn't delete the post. Try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = item.category;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            actions: [
              if (user.isAdmin) ...[
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _edit(context),
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(context),
                ),
              ],
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      category.color.withValues(alpha: 0.35),
                      category.color.withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'news-badge-${item.id}',
                    child: CategoryBadge(category: category, size: 96),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: category.color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fullDate(item.publishedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    item.body,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
