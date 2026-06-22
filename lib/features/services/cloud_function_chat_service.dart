import 'package:blood_donation/core/config/app_env.dart';
import 'package:blood_donation/features/models/chat_message.dart';
import 'package:blood_donation/features/services/chat_service.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Secure OpenAI proxy via Firebase Cloud Functions — API key stays server-side.
class CloudFunctionChatService implements ChatService {
  CloudFunctionChatService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<ChatMessage> send({
    required String userId,
    required String message,
    required Map<String, dynamic> context,
  }) async {
    final callable = _functions.httpsCallable(
      'chatWithOpenAI',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
    );

    final result = await callable.call({
      'message': message.trim(),
      'history': _historyFromContext(context),
      'model': AppEnv.chatModel,
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    final text = (data['text'] ?? '').toString().trim();
    if (text.isEmpty) {
      throw Exception('Empty response from chat service');
    }

    return ChatMessage(
      id: (data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
          .toString(),
      role: ChatRole.assistant,
      text: text,
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
          final role = item['role']?.toString() ?? 'user';
          final text =
              (item['text'] ?? item['content'] ?? '').toString().trim();
          if (text.isEmpty) {
            return null;
          }
          return {
            'role': role == 'assistant' ? 'assistant' : 'user',
            'text': text,
          };
        })
        .whereType<Map<String, String>>()
        .take(6)
        .toList();
  }
}
