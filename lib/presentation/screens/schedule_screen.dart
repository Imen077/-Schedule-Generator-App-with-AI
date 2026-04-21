import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/schedule_model.dart';
import '../widgets/schedule_card.dart';

class ScheduleScreen extends StatelessWidget {
  final List<ScheduleItem> schedule;

  const ScheduleScreen({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            tooltip: 'Done',
          )
        ],
      ),
      body: schedule.isEmpty
          ? const Center(child: Text('No schedule generated.'))
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, Color(0xFF9B94FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Generated Schedule',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${schedule.length} tasks scheduled for today',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: schedule.length,
                    itemBuilder: (ctx, i) =>
                        ScheduleCard(item: schedule[i], index: i),
                  ),
                ),
              ],
            ),
    );
  }
}