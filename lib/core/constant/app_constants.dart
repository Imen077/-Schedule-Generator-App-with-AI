import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel = 'llama-3.1-8b-instant';
}