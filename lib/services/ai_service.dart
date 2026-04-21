import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:schedule_generator/core/constant/app_constants.dart';
import '../data/models/task_model.dart';
import '../data/models/schedule_model.dart';

class AiService {
  Future<List<ScheduleItem>> generateSchedule({
    required List<TaskModel> tasks,
    required String workStartTime,
    required String workEndTime,
    required String breakDuration,
  }) async {
    final taskList = tasks.map((t) => t.toPromptString()).join('\n');

    final prompt = '''
You are a productivity assistant. Generate an optimized daily schedule based on the tasks below.

Work hours: $workStartTime - $workEndTime
Break duration between tasks: $breakDuration minutes

Tasks:
$taskList

Rules:
1. Schedule high priority tasks first
2. Respect deadlines
3. Add short breaks between tasks
4. Distribute workload evenly
5. Respond ONLY with a valid JSON array, no markdown, no explanation.

JSON format:
[
  {
    "time": "09:00",
    "task": "Task name here",
    "duration": 60,
    "priority": "High",
    "note": "Optional tip or note"
  }
]
''';

    final response = await http.post(
      Uri.parse(AppConstants.groqBaseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConstants.groqApiKey}',
      },
      body: jsonEncode({
        'model': AppConstants.groqModel,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a productivity assistant. Always respond with valid JSON only, no markdown, no explanation.',
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'temperature': 0.3,
        'max_tokens': 2048,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Groq API error: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body);
    String rawText = data['choices'][0]['message']['content'];

    rawText = rawText.replaceAll('```json', '').replaceAll('```', '').trim();

    final List<dynamic> jsonList = jsonDecode(rawText);
    return jsonList.map((e) => ScheduleItem.fromJson(e)).toList();
  }
}
