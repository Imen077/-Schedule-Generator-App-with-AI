import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  String _priority = 'Medium';
  DateTime? _deadline;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      durationMinutes: int.parse(_durationController.text.trim()),
      priority: _priority,
      deadline: _deadline,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Task Name
            const Text('Task Name',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'e.g. Study for exam'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter task name' : null,
            ),
            const SizedBox(height: 20),

            // Duration
            const Text('Duration (minutes)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'e.g. 60'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter duration';
                final n = int.tryParse(v);
                if (n == null || n <= 0) return 'Enter valid duration';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Priority
            const Text('Priority',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'Low',
                    label: Text('Low'),
                    icon: Icon(Icons.arrow_downward, size: 16)),
                ButtonSegment(
                    value: 'Medium',
                    label: Text('Medium'),
                    icon: Icon(Icons.remove, size: 16)),
                ButtonSegment(
                    value: 'High',
                    label: Text('High'),
                    icon: Icon(Icons.arrow_upward, size: 16)),
              ],
              selected: {_priority},
              onSelectionChanged: (s) => setState(() => _priority = s.first),
            ),
            const SizedBox(height: 20),

            // Deadline
            const Text('Deadline (optional)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 18, color: AppTheme.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      _deadline == null
                          ? 'No deadline set'
                          : DateFormat('dd MMM yyyy').format(_deadline!),
                      style: TextStyle(
                        color: _deadline == null
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (_deadline != null)
                      GestureDetector(
                        onTap: () => setState(() => _deadline = null),
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.redAccent),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notes
            const Text('Notes (optional)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration:
                  const InputDecoration(hintText: 'Any additional notes...'),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Task',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}