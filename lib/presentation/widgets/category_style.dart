import 'package:flutter/material.dart';

import '../../data/models/news_item.dart';

/// Visual identity of each category. Kept in the presentation layer so the
/// data models stay free of Flutter imports.
extension NewsCategoryStyle on NewsCategory {
  String get label => switch (this) {
        NewsCategory.announcement => 'Announcement',
        NewsCategory.academics => 'Academics',
        NewsCategory.sports => 'Sports',
        NewsCategory.clubs => 'Clubs',
      };

  IconData get icon => switch (this) {
        NewsCategory.announcement => Icons.campaign_outlined,
        NewsCategory.academics => Icons.school_outlined,
        NewsCategory.sports => Icons.sports_soccer_outlined,
        NewsCategory.clubs => Icons.groups_outlined,
      };

  Color get color => switch (this) {
        NewsCategory.announcement => Colors.deepOrange.shade400,
        NewsCategory.academics => Colors.indigo.shade400,
        NewsCategory.sports => Colors.green.shade500,
        NewsCategory.clubs => Colors.purple.shade400,
      };
}

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category, this.size = 56});

  final NewsCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(category.icon, color: category.color, size: size * 0.5),
    );
  }
}
