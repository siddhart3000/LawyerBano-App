import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GrokService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions'; 

  Future<String> getLegalAdvice(String query, String languageCode) async {
    if (_apiKey.isEmpty) return "Configuration Error: API Key missing.";

    String languageInstruction = "";
    if (languageCode == 'hi') {
      languageInstruction = "Please provide the response in Hindi.";
    } else if (languageCode == 'hinglish') {
      languageInstruction = "Please provide the response in Hinglish (Hindi written in English script).";
    } else {
      languageInstruction = "Please provide the response in English.";
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'messages': [
            {
              'role': 'system',
              'content': 'You are the "LawyerBano Professional Legal Repository & AI Counsel". $languageInstruction\n'
                  'Provide legal information based on Indian Law, including BNS (2024) and old IPC sections.\n'
                  'Use a point-wise format for easy reading. Use the following headers exactly for the points:\n'
                  '- [CRIME CLASSIFICATION]\n'
                  '- [STATUTORY CITATION]\n'
                  '- [CONSTITUTIONAL CONTEXT]\n'
                  '- [CASE LAW REFERENCE]\n'
                  '- [EXPERT RECOMMENDATION]\n'
                  '\n'
                  'At the very end of your response, you MUST add a section called "[LAWYER SUGGESTION]" with a real-world style lawyer profile including: Name, Experience, Contact, Email, and status "Open to Work".'
            },
            {'role': 'user', 'content': query}
          ],
          'model': 'llama-3.3-70b-versatile',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        if (content == null || content.toString().isEmpty) {
          return "Error: AI returned an empty response. Please try again.";
        }
        return content.toString();
      } else {
        return "Error: Unable to fetch insights. (Code: ${response.statusCode})";
      }
    } catch (e) {
      return "Stability Error: Failed to parse legal data. Please check your connection.";
    }
  }

  Future<List<Map<String, String>>> getLatestVerdicts() async {
    try {
      // In a real app, you might fetch this from an RSS feed or legal news API
      // Returning at least 4 updates as requested
      return [
        {
          'title': 'SC: Article 21 and Digital Privacy (2024)', 
          'lawyer': 'Justice D.Y. Chandrachud', 
          'time': '10m ago',
        },
        {
          'title': 'BNS Section 103: New Procedural Guidelines', 
          'lawyer': 'Adv. Harish Salve', 
          'time': '2h ago',
        },
        {
          'title': 'Delhi High Court on Virtual Hearings', 
          'lawyer': 'Senior Adv. Kapil Sibal', 
          'time': '5h ago',
        },
        {
          'title': 'New Bar Council Rules for Legal Interns', 
          'lawyer': 'BCI Council', 
          'time': '1d ago',
        },
      ];
    } catch (e) {
      return [];
    }
  }
}
