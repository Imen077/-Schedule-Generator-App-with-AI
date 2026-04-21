class TaskModel {
  final String id;
  final String name;
  final int durationMinutes;
  final String priority; // 'High', 'Medium', 'Low'
  final DateTime? deadline;
  final String? notes;

  TaskModel({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.priority,
    this.deadline,
    this.notes,
  });

  String toPromptString() {
    final deadlineStr = deadline != null
        ? '${deadline!.day}/${deadline!.month}/${deadline!.year}'
        : 'No deadline';
    return '- Task: "$name" | Duration: ${durationMinutes}min | Priority: $priority | Deadline: $deadlineStr${notes != null ? ' | Notes: $notes' : ''}';
  }
}