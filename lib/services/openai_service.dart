import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class OpenAIService {
  final String baseUrl = 'https://api.openai.com/v1';
  final String apiKey = EnvConfig.openaiApiKey;

  // Chat completion for AI assistant
  Future<String> chatCompletion(String message, {List<Map<String, String>>? context}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a medical assistant AI for MediGuardian AI app. 
              Provide accurate, helpful, and safe medication information.
              Always remind users to consult healthcare professionals for medical advice.
              Be clear, concise, and empathetic in your responses.''',
            },
            ...?context,
            {'role': 'user', 'content': message},
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling OpenAI API: $e');
    }
  }

  // Analyze medication safety
  Future<String> analyzeMedicationSafety(List<String> medications) async {
    final message = '''Analyze the safety of these medications when taken together:
${medications.join(', ')}. 
Please provide potential interactions, contraindications, and recommendations.''';

    return await chatCompletion(message);
  }

  // Get medication information
  Future<String> getMedicationInfo(String medicationName) async {
    final message = '''Provide detailed information about ${medicationName} including:
- Uses and indications
- Common side effects
- Important precautions
- Recommended dosage guidelines
- Contraindications''';

    return await chatCompletion(message);
  }

  // Answer medication questions
  Future<String> answerQuestion(String question) async {
    return await chatCompletion(question);
  }
}
