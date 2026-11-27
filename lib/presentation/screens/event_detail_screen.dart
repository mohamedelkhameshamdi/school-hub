import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../data/models/app_user.dart';
import '../../data/models/event_item.dart';
import '../../data/models/participant.dart';
import '../../data/repositories/school_repository.dart';
import '../widgets/dialogs.dart';
import 'event_form_screen.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.item,
    required this.repository,
    required this.user,
  });

  final EventItem item;
  final SchoolRepository repository;
  final AppUser user;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _busy = false;

  late final Stream<List<Participant>> _participants =
      widget.repository.watchParticipants(widget.item.id);

  bool get _ended => widget.item.end.isBefore(DateTime.now());

  Future<void> _toggle(bool joined) async {
    setState(() => _busy = true);
    try {
      if (joined) {
        await widget.repository.leaveEvent(widget.item.id, widget.user.uid);
      } else {
        await widget.repository.joinEvent(widget.item.id, widget.user);
      }
    } catch (_) {
      if (mounted) {
        showMessage(context, "Couldn't update your registration. Try again.");
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EventFormScreen(
          repository: widget.repository,
          existing: widget.item,
        ),
      ),
    );
    if (saved == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final ok = await confirmDelete(
      context,
      title: 'Delete this event?',
      message: 'Everyone who joined will be removed from it. '
          'This cannot be undone.',
    );
    if (!ok || !mounted) return;
    try {
      await widget.repository.deleteEvent(widget.item.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) showMessage(context, "Couldn't delete the event. Try again.");
    }
  }

  Widget _joinButton(bool joined) {
    final style = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
    );
    if (_ended) {
      return FilledButton(
        onPressed: null,
        style: style,
        child: const Text('This event has ended'),
      );
    }
    if (_busy) {
      return FilledButton(
        onPressed: null,
        style: style,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }
    if (joined) {
      return FilledButton.tonalIcon(
        onPressed: () => _toggle(true),
        style: style,
        icon: const Icon(Icons.check_circle),
        label: const Text("You're going · Tap to leave"),
      );
    }
    return FilledButton.icon(
      onPressed: () => _toggle(false),
      style: style,
      icon: const Icon(Icons.how_to_reg_outlined),
      label: const Text('Join this event'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final item = widget.item;
    final isAdmin = widget.user.isAdmin;

    return StreamBuilder<List<Participant>>(
      stream: _participants,
      builder: (context, snapshot) {
        final people = snapshot.data ?? const <Participant>[];
        final joined = people.any((p) => p.uid == widget.user.uid);

        return Scaffold(
          appBar: AppBar(
            actions: [
              if (isAdmin) ...[
                IconButton(
                  tooltip: 'Edit event',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: _edit,
                ),
                IconButton(
                  tooltip: 'Delete event',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _delete,
                ),
              ],
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    dayLabel(item.start),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 28),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  title: fullDate(item.start),
                  subtitle: '${timeOf(item.start)} – ${timeOf(item.end)}',
                ),
                const SizedBox(height: 16),
                _InfoRow(icon: Icons.place_outlined, title: item.location),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.groups_outlined,
                  title: isAdmin
                      ? '${people.length} registered'
                      : (people.isEmpty
                          ? 'Be the first to join'
                          : '${people.length} going'),
                ),
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 20),
                Text(
                  'About this event',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 28),
                  Text(
                    'Attendees (${people.length})',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  if (people.isEmpty)
                    Text(
                      'No one has joined yet.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final p in people)
                          Chip(
                            avatar: CircleAvatar(
                              child: Text(
                                p.name.isEmpty ? '?' : p.name[0].toUpperCase(),
                              ),
                            ),
                            label: Text(p.name),
                          ),
                      ],
                    ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: isAdmin
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: _joinButton(joined),
                  ),
                ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: scheme.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
