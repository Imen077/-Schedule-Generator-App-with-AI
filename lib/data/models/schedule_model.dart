class ScheduleItem {
  final String time;
  final String taskName;
  final int durationMinutes;
  final String priority;
  final String? note;

  ScheduleItem({
    required this.time,
    required this.taskName,
    required this.durationMinutes,
    required this.priority,
    this.note,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      time: json['time'] ?? '',
      taskName: json['task'] ?? '',
      durationMinutes: json['duration'] ?? 0,
      priority: json['priority'] ?? 'Medium',
      note: json['note'],
    );
  }
}