import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/event_item.dart';
import '../models/news_item.dart';
import '../models/participant.dart';
import '../models/plan_item.dart';
import 'school_repository.dart';

typedef _Doc = QueryDocumentSnapshot<Map<String, dynamic>>;

class FirestoreSchoolRepository implements SchoolRepository {
  FirestoreSchoolRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _news =>
      _db.collection('news');
  CollectionReference<Map<String, dynamic>> get _events =>
      _db.collection('events');
  CollectionReference<Map<String, dynamic>> get _plans =>
      _db.collection('plans');

  // ---------------------------------------------------------------- news

  @override
  Stream<List<NewsItem>> watchNews() => _news
      .orderBy('publishedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(_newsFrom).toList());

  @override
  Future<void> saveNews(NewsItem item) async {
    final data = <String, dynamic>{
      'title': item.title,
      'summary': item.summary,
      'body': item.body,
      'category': item.category.name,
      'publishedAt': Timestamp.fromDate(item.publishedAt),
    };
    if (item.id.isEmpty) {
      await _news.add(data);
    } else {
      await _news.doc(item.id).update(data);
    }
  }

  @override
  Future<void> deleteNews(String id) async {
    await _news.doc(id).delete();
  }

  NewsItem _newsFrom(_Doc doc) {
    final m = doc.data();
    return NewsItem(
      id: doc.id,
      title: m['title'] as String? ?? '',
      summary: m['summary'] as String? ?? '',
      body: m['body'] as String? ?? '',
      category: NewsCategory.values.firstWhere(
        (c) => c.name == m['category'],
        orElse: () => NewsCategory.announcement,
      ),
      publishedAt: _date(m['publishedAt']),
    );
  }

  // -------------------------------------------------------------- events

  @override
  Stream<List<EventItem>> watchEvents({bool upcomingOnly = true}) {
    Query<Map<String, dynamic>> query = _events;
    if (upcomingOnly) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      query = query.where(
        'start',
        isGreaterThanOrEqualTo: Timestamp.fromDate(today),
      );
    }
    return query
        .orderBy('start')
        .snapshots()
        .map((snap) => snap.docs.map(_eventFrom).toList());
  }

  @override
  Future<void> saveEvent(EventItem item) async {
    final data = <String, dynamic>{
      'title': item.title,
      'description': item.description,
      'location': item.location,
      'start': Timestamp.fromDate(item.start),
      'end': Timestamp.fromDate(item.end),
    };
    if (item.id.isEmpty) {
      await _events.add(data);
    } else {
      await _events.doc(item.id).update(data);
    }
  }

  /// Firestore does not delete sub-collections automatically, so the
  /// participants are removed in the same batch as the event.
  @override
  Future<void> deleteEvent(String id) async {
    final ref = _events.doc(id);
    final participants = await ref.collection('participants').get();
    final batch = _db.batch();
    for (final doc in participants.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(ref);
    await batch.commit();
  }

  EventItem _eventFrom(_Doc doc) {
    final m = doc.data();
    final start = _date(m['start']);
    return EventItem(
      id: doc.id,
      title: m['title'] as String? ?? '',
      description: m['description'] as String? ?? '',
      location: m['location'] as String? ?? '',
      start: start,
      end: m['end'] == null ? start : _date(m['end']),
    );
  }

  // -------------------------------------------------------- participants

  @override
  Stream<List<Participant>> watchParticipants(String eventId) => _events
      .doc(eventId)
      .collection('participants')
      .orderBy('joinedAt')
      .snapshots()
      .map(
        (snap) => snap.docs.map((doc) {
          final m = doc.data();
          return Participant(
            uid: doc.id,
            name: m['name'] as String? ?? 'Student',
            joinedAt: _date(m['joinedAt']),
          );
        }).toList(),
      );

  @override
  Future<void> joinEvent(String eventId, AppUser user) async {
    await _events.doc(eventId).collection('participants').doc(user.uid).set({
      'uid': user.uid,
      'name': user.name,
      'joinedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<void> leaveEvent(String eventId, String uid) async {
    await _events.doc(eventId).collection('participants').doc(uid).delete();
  }

  // --------------------------------------------------------------- plans

  @override
  Stream<List<PlanItem>> watchPlans() => _plans
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs.map((doc) {
          final m = doc.data();
          return PlanItem(
            id: doc.id,
            title: m['title'] as String? ?? '',
            period: m['period'] as String? ?? '',
            description: m['description'] as String? ?? '',
            createdAt: _date(m['createdAt']),
          );
        }).toList(),
      );

  @override
  Future<void> savePlan(PlanItem item) async {
    final data = <String, dynamic>{
      'title': item.title,
      'period': item.period,
      'description': item.description,
      'createdAt': Timestamp.fromDate(item.createdAt),
    };
    if (item.id.isEmpty) {
      await _plans.add(data);
    } else {
      await _plans.doc(item.id).update(data);
    }
  }

  @override
  Future<void> deletePlan(String id) async {
    await _plans.doc(id).delete();
  }

  DateTime _date(Object? value) =>
      value is Timestamp ? value.toDate() : DateTime.now();
}
