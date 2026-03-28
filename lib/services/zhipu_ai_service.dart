import 'dart:convert';

import 'package:http/http.dart' as http;

class ZhipuAiService {
  static const String _apiUrl =
      'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  static const String _apiKey =
      '68bc06fc66a94e5b8dd2baf0dfb03a62.EsXF4CBDkZiCCJGX';

  Future<String> sendConversation(
    List<Map<String, String>> conversation,
  ) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'glm-4-flash',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful fitness assistant. Reply in English only.',
          },
          ...conversation,
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('AI request failed: ${response.statusCode}');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> choices = data['choices'] as List<dynamic>? ?? [];
    if (choices.isEmpty) {
      throw Exception('Empty AI response');
    }

    final Map<String, dynamic> first =
        choices.first as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> message =
        first['message'] as Map<String, dynamic>? ?? {};
    final String content = message['content']?.toString() ?? '';
    if (content.trim().isEmpty) {
      throw Exception('AI returned no content');
    }
    return content.trim();
  }

  Future<String> sendMessage(String userText) {
    return sendConversation(<Map<String, String>>[
      {
        'role': 'user',
        'content': userText,
      },
    ]);
  }
}
