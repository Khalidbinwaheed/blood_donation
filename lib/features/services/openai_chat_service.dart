import 'package:blood_donation/core/config/app_env.dart';
import 'package:blood_donation/features/models/chat_message.dart';
import 'package:blood_donation/features/services/chat_service.dart';
import 'package:dio/dio.dart';

/// Production OpenAI chat completions integration for the Health Helper.
class OpenAiChatService implements ChatService {
  OpenAiChatService(this._dio);

  final Dio _dio;

  static const _systemPrompt = '''
You are Lifeline Health Helper inside a blood donation and emergency health app.
Give concise, practical guidance about blood donation eligibility, recovery, appointments, and emergencies.
Do not provide medical diagnoses or prescribe medication.
For life-threatening symptoms, tell the user to call local emergency services immediately.
Keep responses under 140 words unless the user asks for detail.
''';

  @override
  Future<ChatMessage> send({
    required String userId,
    required String message,
    required Map<String, dynamic> context,
  }) async {
    if (!AppEnv.hasOpenAi) {
      throw Exception('OPENAI_API_KEY is not configured');
    }

    final cleanMessage = _sanitizeUserText(message);
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
      ..._historyFromContext(context),
      {'role': 'user', 'content': cleanMessage},
    ];

    final response = await _dio.post<Map<String, dynamic>>(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${AppEnv.openAiApiKey}',
          'Content-Type': 'application/json',
        },
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 45),
      ),
      data: {
        'model': AppEnv.openAiModel,
        'messages': messages,
        'temperature': 0.4,
        'max_tokens': 400,
        'user': userId,
      },
    );

    final data = response.data ?? const <String, dynamic>{};
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw Exception('OpenAI returned an empty response');
    }

    final first = choices.first;
    final content = first is Map<String, dynamic>
        ? (((first['message'] as Map<String, dynamic>?)?['content']) ?? '')
            .toString()
            .trim()
        : '';

    if (content.isEmpty) {
      throw Exception('OpenAI returned blank content');
    }

    return ChatMessage(
      id: (data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
          .toString(),
      role: ChatRole.assistant,
      text: content,
      createdAt: DateTime.now(),
    );
  }

  List<Map<String, String>> _historyFromContext(Map<String, dynamic> context) {
    final raw = context['history'];
    if (raw is! List) {
      return const [];
    }

    return raw
        .whereType<Map>()
        .map((item) {
          final role = (item['role'] ?? 'user').toString().toLowerCase();
          final text = (item['text'] ?? '').toString().trim();
          if (text.isEmpty) {
            return null;
          }
          final mappedRole = role == 'assistant' ? 'assistant' : 'user';
          return {'role': mappedRole, 'content': text};
        })
        .whereType<Map<String, String>>()
        .toList();
  }

  String _sanitizeUserText(String text) {
    final trimmed = text.trim();
    final noControls = trimmed.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ');
    return noControls.length > 1200
        ? noControls.substring(0, 1200)
        : noControls;
  }
}
