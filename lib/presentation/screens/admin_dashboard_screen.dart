import 'package:flutter/material.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/school_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
    required this.repository,
    required this.user,
    required this.onNewEvent,
    required this.onNewNews,
    required this.onNewPlan,
  });

  final SchoolRepository repository;
  final AppUser user;
  final VoidCallback onNewEvent;
  final VoidCallback onNewNews;
  final VoidCallback onNewPlan;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final Stream<int> _upcomingEvents = widget.repository
      .watchEvents(upcomingOnly: false)
      .map(
        (events) =>
            events.where((e) => !e.start.isBefore(DateTime.now())).length,
      );

  late final Stream<int> _newsCount =
      widget.repository.watchNews().map((items) => items.length);

  late final Stream<int> _planCount =
      widget.repository.watchPlans().map((items) => items.length);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Welcome, ${widget.user.name}',
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage what students see on School Hub.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.event_outlined,
                  label: 'Upcoming events',
                  stream: _upcomingEvents,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.article_outlined,
                  label: 'News posts',
                  stream: _newsCount,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.flag_outlined,
                  label: 'Plans',
                  stream: _planCount,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Quick actions',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: widget.onNewEvent,
              icon: const Icon(Icons.event_available_outlined),
              label: const Text('New event'),
            ),
            FilledButton.tonalIcon(
              onPressed: widget.onNewNews,
              icon: const Icon(Icons.campaign_outlined),
              label: const Text('Post news'),
            ),
            FilledButton.tonalIcon(
              onPressed: widget.onNewPlan,
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Add plan'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Open an event to see who joined, edit its details or '
                  'delete it. Changes appear instantly for every student.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.stream,
  });

  final IconData icon;
  final String label;
  final Stream<int> stream;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: 12),
          StreamBuilder<int>(
            stream: stream,
            builder: (context, snapshot) => Text(
              snapshot.hasData ? '${snapshot.data}' : '–',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
