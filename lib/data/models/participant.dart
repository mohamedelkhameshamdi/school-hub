class Participant {
  const Participant({
    required this.uid,
    required this.name,
    required this.joinedAt,
  });

  final String uid;
  final String name;
  final DateTime joinedAt;
}
