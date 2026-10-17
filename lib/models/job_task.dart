enum TaskType { oficio, ayudaRapida }

class JobTask {
  final String id;
  final String title;
  final String category;
  final String description;
  final String schedule;
  final double payment;
  final String distance;
  final TaskType type;
  final double latitude;
  final double longitude;

  JobTask({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.schedule,
    required this.payment,
    required this.distance,
    required this.type,
    required this.latitude,
    required this.longitude,
  });
}