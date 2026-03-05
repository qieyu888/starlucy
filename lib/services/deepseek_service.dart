import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepSeekService {
  static const String _apiKey = 'sk-c67ef4ef9f664020a743b4294baabc22';
  static const String _baseUrl = 'https://api.deepseek.com/v1/chat/completions';

  Future<String> sendMessage(String message, List<Map<String, String>> history) async {
    try {
      final messages = [
        {
          'role': 'system',
          'content': '你是 Echo，一个温柔、善解人意的 AI 助手。你的任务是倾听用户的心情和想法，给予温暖、治愈的回应。回复要简洁、真诚，充满共情。使用温柔的语气，像朋友一样交流。'
        },
        ...history,
        {'role': 'user', 'content': message},
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'deepseek-chat',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        return '抱歉，我现在有点累了，稍后再聊好吗？';
      }
    } catch (e) {
      return '网络似乎不太稳定，要不稍后再试试？';
    }
  }
}
