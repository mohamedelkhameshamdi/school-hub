import '../models/event_item.dart';
import '../models/news_item.dart';

/// The UI only depends on this contract. Today it is backed by mock data;
/// later you can add an ApiSchoolRepository without touching any screen.
abstract class SchoolRepository {
  Future<List<NewsItem>> fetchNews();
  Future<List<EventItem>> fetchEvents();
}
