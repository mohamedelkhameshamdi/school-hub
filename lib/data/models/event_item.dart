class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.start,
    required this.end,
  });

  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime start;
  final DateTime end;
}
