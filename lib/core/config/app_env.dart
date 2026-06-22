class AppEnv {
  AppEnv._();

  static const String appName =
      String.fromEnvironment('APP_NAME', defaultValue: 'Lifeline');
  static const String newsApiUrl = String.fromEnvironment('NEWS_API_URL');
  static const String newsApiKey = String.fromEnvironment('NEWS_API_KEY');
  static const String newsStreamUrl = String.fromEnvironment('NEWS_STREAM_URL');
  static const String chatbotApiUrl = String.fromEnvironment('CHATBOT_API_URL');
  static const String placesApiUrl = String.fromEnvironment('PLACES_API_URL');
  static const String backendUrl = String.fromEnvironment('BACKEND_URL');
  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String openAiModel = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-4o-mini',
  );
  static const String githubModelsModel = String.fromEnvironment(
    'GITHUB_MODELS_MODEL',
    defaultValue: 'openai/gpt-4.1-mini',
  );
  static const String githubApiVersion = String.fromEnvironment(
    'GITHUB_API_VERSION',
    defaultValue: '2022-11-28',
  );
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://blooddonation-89361.web.app/privacy',
  );
  static const String googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const String googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const String defaultRegion =
      String.fromEnvironment('REGION', defaultValue: 'US');
  static const String defaultLang =
      String.fromEnvironment('LANG', defaultValue: 'en');
  static const int newsRefreshMinutes = int.fromEnvironment(
    'NEWS_REFRESH_MINUTES',
    defaultValue: 15,
  );
  static const String ambulanceNumber =
      String.fromEnvironment('AMBULANCE_NUMBER', defaultValue: '1122');
  static const String appShareUrl = String.fromEnvironment(
    'APP_SHARE_URL',
    defaultValue: 'https://lifeline.app',
  );
  static const bool useMockServices = bool.fromEnvironment(
    'USE_MOCK_SERVICES',
    defaultValue: false,
  );
  static const bool useCloudChat = bool.fromEnvironment(
    'USE_CLOUD_CHAT',
    defaultValue: true,
  );
  static const bool allowClientOpenAi = bool.fromEnvironment(
    'ALLOW_CLIENT_OPENAI',
    defaultValue: false,
  );

  static bool get hasNewsApi => newsApiUrl.trim().isNotEmpty;
  static bool get hasChatbotApi => chatbotApiUrl.trim().isNotEmpty;
  static bool get hasPlacesApi => placesApiUrl.trim().isNotEmpty;
  static bool get hasOpenAi => openAiApiKey.trim().isNotEmpty;
  static bool get hasGoogleMapsApi => googleMapsApiKey.trim().isNotEmpty;
  static bool get hasGoogleWebClientId => googleWebClientId.trim().isNotEmpty;
  static bool get hasPrivacyPolicy => privacyPolicyUrl.trim().isNotEmpty;
  static String get chatModel => githubModelsModel.trim().isNotEmpty
      ? githubModelsModel
      : openAiModel;
}
