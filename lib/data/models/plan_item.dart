/// A school plan or program, e.g. "Semester 1 programme".
class PlanItem {
  const PlanItem({
    required this.id,
    required this.title,
    required this.period,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String period;
  final String description;
  final DateTime createdAt;
}
