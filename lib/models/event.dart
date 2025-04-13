class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String categoryId;
  bool isNotificationOn;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.categoryId,
    this.isNotificationOn = true,
  });
}
