import 'package:flutter/material.dart';

import '../../data/models/event_item.dart';
import '../../data/repositories/school_repository.dart';
import '../widgets/async_list.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key, required this.repository});

  final SchoolRepository repository;

  @override
  Widget build(BuildContext context) {
    return AsyncList<EventItem>(
      load: repository.fetchEvents,
      emptyMessage: 'No upcoming events.\nEnjoy the free time!',
      itemBuilder: (context, item) => EventCard(
        item: item,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EventDetailScreen(item: item)),
        ),
      ),
    );
  }
}
