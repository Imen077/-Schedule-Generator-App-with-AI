import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onDelete;

  const TaskCard({super.key, required this.task, required this.onDelete});

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red.shade400;
      case 'Medium':
        return Colors.orange.shade400;
      default:
        return Colors.green.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _priorityColor(task.priority).withOpacity(0.15),
          child: Icon(Icons.task_alt, color: _priorityColor(task.priority)),
        ),
        title: Text(
          task.name,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        subtitle: Text(
          '${task.durationMinutes} min • ${task.priority} Priority',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}