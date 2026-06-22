import 'package:blood_donation/core/config/app_env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnv production flags', () {
    test('cloud chat is enabled by default', () {
      expect(AppEnv.useCloudChat, isTrue);
    });

    test('client OpenAI is disabled by default', () {
      expect(AppEnv.allowClientOpenAi, isFalse);
    });

    test('github models model defaults for cloud chat', () {
      expect(AppEnv.chatModel, 'openai/gpt-4.1-mini');
      expect(AppEnv.githubApiVersion, '2022-11-28');
    });
  });
}
