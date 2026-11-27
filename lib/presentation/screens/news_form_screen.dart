import 'package:flutter/material.dart';

import '../../data/models/news_item.dart';
import '../../data/repositories/school_repository.dart';
import '../widgets/category_style.dart';
import '../widgets/form_shell.dart';

class NewsFormScreen extends StatefulWidget {
  const NewsFormScreen({super.key, required this.repository, this.existing});

  final SchoolRepository repository;
  final NewsItem? existing;

  @override
  State<NewsFormScreen> createState() => _NewsFormScreenState();
}

class _NewsFormScreenState extends State<NewsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title);
  late final TextEditingController _summary =
      TextEditingController(text: widget.existing?.summary);
  late final TextEditingController _body =
      TextEditingController(text: widget.existing?.body);
  late NewsCategory _category =
      widget.existing?.category ?? NewsCategory.announcement;

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.saveNews(
        NewsItem(
          id: widget.existing?.id ?? '',
          title: _title.text.trim(),
          summary: _summary.text.trim(),
          body: _body.text.trim(),
          category: _category,
          publishedAt: widget.existing?.publishedAt ?? DateTime.now(),
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = "Couldn't publish. Check your connection and try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormShell(
      title: widget.existing == null ? 'Post news' : 'Edit news',
      saveLabel: widget.existing == null ? 'Publish' : 'Save changes',
      formKey: _formKey,
      saving: _saving,
      error: _error,
      onSave: _save,
      children: [
        TextFormField(
          controller: _title,
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDecoration('Title', icon: Icons.title),
          validator: notEmpty('Enter a title', min: 3),
        ),
        TextFormField(
          controller: _summary,
          minLines: 2,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDecoration(
            'Short summary',
            hint: 'Shown in the news list',
          ),
          validator: notEmpty('Add a short summary', min: 5),
        ),
        TextFormField(
          controller: _body,
          minLines: 6,
          maxLines: 14,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDecoration('Full article'),
          validator: notEmpty('Write the full article', min: 10),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in NewsCategory.values)
                  ChoiceChip(
                    avatar: Icon(c.icon, size: 18, color: c.color),
                    label: Text(c.label),
                    selected: c == _category,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
