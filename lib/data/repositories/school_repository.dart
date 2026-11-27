import '../models/app_user.dart';
import '../models/event_item.dart';
import '../models/news_item.dart';
import '../models/participant.dart';
import '../models/plan_item.dart';

/// The UI only depends on this contract. Lists are live streams, so every
/// change made by an admin appears on every screen instantly.
abstract class SchoolRepository {
  Stream<List<NewsItem>> watchNews();
  Stream<List<EventItem>> watchEvents({bool upcomingOnly = true});
  Stream<List<PlanItem>> watchPlans();
  Stream<List<Participant>> watchParticipants(String eventId);

  /// An empty id means "create", otherwise "update".
  Future<void> saveNews(NewsItem item);
  Future<void> deleteNews(String id);
  Future<void> saveEvent(EventItem item);
  Future<void> deleteEvent(String id);
  Future<void> savePlan(PlanItem item);
  Future<void> deletePlan(String id);

  Future<void> joinEvent(String eventId, AppUser user);
  Future<void> leaveEvent(String eventId, String uid);
}
