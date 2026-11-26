import '../models/event_item.dart';
import '../models/news_item.dart';
import 'school_repository.dart';

class MockSchoolRepository implements SchoolRepository {
  /// Set to true to preview the error state.
  MockSchoolRepository({this.simulateError = false});

  final bool simulateError;

  Future<void> _fakeNetwork() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (simulateError) throw Exception('Network error');
  }

  @override
  Future<List<NewsItem>> fetchNews() async {
    await _fakeNetwork();
    final now = DateTime.now();
    return [
      NewsItem(
        id: 'n1',
        title: 'First-semester exam timetable is now online',
        summary: 'Check your group schedule and room assignments before Monday.',
        body:
            'The exam timetable for the first semester has been published. Each group can now see its dates, start times and rooms.\n\n'
            'Please arrive at least 15 minutes before each exam and bring your student card. Phones and smartwatches must be switched off and left in your bag.\n\n'
            'If you notice a conflict between two exams, contact the administration office before Monday so it can be resolved in time.',
        category: NewsCategory.academics,
        publishedAt: now.subtract(const Duration(hours: 3)),
      ),
      NewsItem(
        id: 'n2',
        title: 'Library extends opening hours during exam period',
        summary: 'Open until 20:00 on weekdays starting next week.',
        body:
            'To support students preparing for exams, the library will stay open until 20:00 from Monday to Friday.\n\n'
            'Quiet study rooms can be booked at the front desk for up to two hours. Please keep the reading areas silent and clear your table when you leave.',
        category: NewsCategory.announcement,
        publishedAt: now.subtract(const Duration(hours: 9)),
      ),
      NewsItem(
        id: 'n3',
        title: 'Inter-class football tournament: registrations open',
        summary: 'Teams of 7 players. Sign up with your class representative.',
        body:
            'The yearly inter-class football tournament is back. Each class can register one team of seven players plus up to three substitutes.\n\n'
            'Matches take place after classes on the main sports field. The final is open to the whole school, so bring your friends to cheer.',
        category: NewsCategory.sports,
        publishedAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      NewsItem(
        id: 'n4',
        title: 'Robotics club is looking for new members',
        summary: 'No experience needed. Come and build something this semester.',
        body:
            'The robotics club is welcoming new members of every level. Beginners will start with small Arduino projects, while advanced members work on the autonomous robot for the spring competition.\n\n'
            'Meetings are every Thursday afternoon in Lab 3. Just show up, we will provide the parts.',
        category: NewsCategory.clubs,
        publishedAt: now.subtract(const Duration(days: 2, hours: 5)),
      ),
      NewsItem(
        id: 'n5',
        title: 'Campus Wi-Fi maintenance this weekend',
        summary: 'Connection may be unstable on Saturday morning.',
        body:
            'The IT department will upgrade the campus network on Saturday between 08:00 and 12:00. During this time the Wi-Fi may be slow or unavailable.\n\n'
            'Please save your online work in advance. Normal service will resume by noon.',
        category: NewsCategory.announcement,
        publishedAt: now.subtract(const Duration(days: 3)),
      ),
      NewsItem(
        id: 'n6',
        title: 'Guest lecture: careers in cloud engineering',
        summary: 'An industry engineer shares tips on internships and first jobs.',
        body:
            'A cloud engineer from a partner company will talk about day-to-day work, the skills employers look for, and how to land your first internship.\n\n'
            'There will be a Q&A at the end. Seats are limited, so arrive early.',
        category: NewsCategory.academics,
        publishedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Future<List<EventItem>> fetchEvents() async {
    await _fakeNetwork();
    final now = DateTime.now();
    DateTime at(int plusDays, int hour, [int minute = 0]) =>
        DateTime(now.year, now.month, now.day + plusDays, hour, minute);

    return [
      EventItem(
        id: 'e1',
        title: 'Library group study session',
        description:
            'Bring your notes and prepare for the upcoming exams with classmates. Quiet rooms are reserved for the group on the second floor.',
        location: 'Library, 2nd floor',
        start: at(0, 17),
        end: at(0, 19),
      ),
      EventItem(
        id: 'e2',
        title: 'Guest lecture: careers in cloud engineering',
        description:
            'An engineer from a partner company talks about internships, skills and first jobs in the cloud industry. A Q&A follows the talk.',
        location: 'Amphitheater A',
        start: at(1, 10),
        end: at(1, 12),
      ),
      EventItem(
        id: 'e3',
        title: 'Robotics club open workshop',
        description:
            'Try building and programming a small robot with the club members. All levels are welcome and all materials are provided.',
        location: 'Lab 3, Building B',
        start: at(2, 14),
        end: at(2, 17),
      ),
      EventItem(
        id: 'e4',
        title: 'Inter-class football final',
        description:
            'The two best classes face each other in the tournament final. Everyone is invited to come and support their class.',
        location: 'Main sports field',
        start: at(4, 16, 30),
        end: at(4, 18, 30),
      ),
      EventItem(
        id: 'e5',
        title: 'Career fair',
        description:
            'Meet local companies, drop off your CV and ask questions about internships and graduate programs.',
        location: 'Main hall',
        start: at(6, 9),
        end: at(6, 13),
      ),
      EventItem(
        id: 'e6',
        title: 'Open mic and talent night',
        description:
            'Music, poetry, comedy or magic: share your talent on stage or simply enjoy the show with friends.',
        location: 'Student café',
        start: at(9, 18),
        end: at(9, 20),
      ),
    ];
  }
}
