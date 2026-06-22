import 'package:blood_donation/features/models/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ChatMessage.fromJson parses role and fields', () {
    final json = {
      'id': 'm_1',
      'role': 'assistant',
      'text': 'Hello, how can I help?',
      'createdAt': '2026-02-16T15:32:00Z',
    };

    final message = ChatMessage.fromJson(json);

    expect(message.id, 'm_1');
    expect(message.role, ChatRole.assistant);
    expect(message.text, contains('help'));
    expect(message.hasError, isFalse);
  });
}
