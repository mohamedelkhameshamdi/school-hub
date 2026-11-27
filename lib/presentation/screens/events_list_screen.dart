import 'package:flutter/material.dart';

import '../../data/models/app_user.dart';
import '../../data/models/event_item.dart';
import '../../data/repositories/school_repository.dart';
import '../widgets/async_list.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({
    super.key,
    required this.repository,
    required this.user,
  });

  final SchoolRepository repository;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return AsyncList<EventItem>(
      // Students see upcoming events; admins see everything to manage it.
      stream: () => repository.watchEvents(upcomingOnly: !user.isAdmin),
      emptyMessage: user.isAdmin
          ? 'No events yet.\nTap "New event" to create the first one.'
          : 'No upcoming events.\nCheck back soon.',
      itemBuilder: (context, item) => EventCard(
        item: item,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => EventDetailScreen(
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
