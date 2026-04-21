import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/task_model.dart';
import '../../services/ai_service.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';
import 'schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TaskModel> _tasks = [];
  final AiService _geminiService = AiService();
  bool _isLoading = false;

  // Work preferences (simple defaults)
  String _workStart = '09:00';
  String _workEnd = '17:00';
  String _breakDuration = '10';

  Future<void> _addTask() async {
    final result = await Navigator.push<TaskModel>(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
    if (result != null) setState(() => _tasks.add(result));
  }

  void _removeTask(String id) {
    setState(() => _tasks.removeWhere((t) => t.id == id));
  }

  Future<void> _generateSchedule() async {
    if (_tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one task first!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final schedule = await _geminiService.generateSchedule(
        tasks: _tasks,
        workStartTime: _workStart,
        workEndTime: _workEnd,
        breakDuration: _breakDuration,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ScheduleScreen(schedule: schedule)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showWorkPreferences() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _WorkPreferencesSheet(
        workStart: _workStart,
        workEnd: _workEnd,
        breakDuration: _breakDuration,
        onSave: (start, end, brk) {
          setState(() {
            _workStart = start;
            _workEnd = end;
            _breakDuration = brk;
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Generator',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showWorkPreferences,
            tooltip: 'Work Preferences',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _SummaryChip(icon: Icons.task, label: '${_tasks.length} Tasks'),
                const SizedBox(width: 12),
                _SummaryChip(
                    icon: Icons.schedule, label: '$_workStart - $_workEnd'),
                const SizedBox(width: 12),
                _SummaryChip(
                    icon: Icons.coffee, label: '$_breakDuration min break'),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: _tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No tasks yet',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Tap + to add your first task',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (ctx, i) => TaskCard(
                      task: _tasks[i],
                      onDelete: () => _removeTask(_tasks[i].id),
                    ),
                  ),
          ),

          // Generate button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateSchedule,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isLoading ? 'Generating...' : 'Generate Schedule with AI',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _WorkPreferencesSheet extends StatefulWidget {
  final String workStart, workEnd, breakDuration;
  final Function(String, String, String) onSave;

  const _WorkPreferencesSheet({
    required this.workStart,
    required this.workEnd,
    required this.breakDuration,
    required this.onSave,
  });

  @override
  State<_WorkPreferencesSheet> createState() => _WorkPreferencesSheetState();
}

class _WorkPreferencesSheetState extends State<_WorkPreferencesSheet> {
  late String _start, _end, _brk;

  @override
  void initState() {
    super.initState();
    _start = widget.workStart;
    _end = widget.workEnd;
    _brk = widget.breakDuration;
  }

  Future<void> _pickTime(bool isStart) async {
    final parts = (isStart ? _start : _end).split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() => isStart ? _start = formatted : _end = formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Work Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start Time',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _pickTime(true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 18),
                            const SizedBox(width: 8),
                            Text(_start),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('End Time',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _pickTime(false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 18),
                            const SizedBox(width: 8),
                            Text(_end),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Break Duration (minutes)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _brk,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
            items: ['5', '10', '15', '20', '30']
                .map((v) =>
                    DropdownMenuItem(value: v, child: Text('$v minutes')))
                .toList(),
            onChanged: (v) => setState(() => _brk = v!),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSave(_start, _end, _brk),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Preferences',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
