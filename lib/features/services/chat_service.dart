import 'dart:convert';

import 'package:blood_donation/core/config/app_env.dart';
import 'package:blood_donation/features/models/chat_message.dart';
import 'package:dio/dio.dart';

abstract class ChatService {
  Future<ChatMessage> send({
    required String userId,
    required String message,
    required Map<String, dynamic> context,
  });
}

class ApiChatService implements ChatService {
  ApiChatService(this._dio);

  final Dio _dio;

  @override
  Future<ChatMessage> send({
    required String userId,
    required String message,
    required Map<String, dynamic> context,
  }) async {
    if (!AppEnv.hasChatbotApi) {
      throw Exception('CHATBOT_API_URL is not configured');
    }

    final cleanMessage = _sanitizeUserText(message);
    final cleanContext = _sanitizeContext(context);

    final response = await _dio.post<Map<String, dynamic>>(
      AppEnv.chatbotApiUrl,
      data: {
        'userId': userId,
        'message': cleanMessage,
        'context': cleanContext,
      },
    );
    final data = response.data ?? const <String, dynamic>{};
    final assistantMessage =
        (data['response'] ?? data['message'] ?? data['text'] ?? '').toString();

    return ChatMessage(
      id: (data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
          .toString(),
      role: ChatRole.assistant,
      text: assistantMessage.trim(),
      createdAt: DateTime.now(),
      error: assistantMessage.trim().isEmpty ? 'Empty response' : null,
    );
  }

  String _sanitizeUserText(String text) {
    final trimmed = text.trim();
    final noControls = trimmed.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ');
    return noControls.length > 1200
        ? noControls.substring(0, 1200)
        : noControls;
  }

  Map<String, dynamic> _sanitizeContext(Map<String, dynamic> context) {
    final encoded = jsonEncode(context);
    if (encoded.length <= 5000) {
      return context;
    }
    return {
      'truncated': true,
      'summary': encoded.substring(0, 5000),
    };
  }
}

class MockChatService implements ChatService {
  const MockChatService();

  @override
  Future<ChatMessage> send({
    required String userId,
    required String message,
    required Map<String, dynamic> context,
  }) async {
    throw UnimplementedError(
      'MockChatService is available for tests only.',
    );
  }
}
