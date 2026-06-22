import 'package:blood_donation/core/config/app_env.dart';
import 'package:blood_donation/core/network/dio_client.dart';
import 'package:blood_donation/features/services/chat_service.dart';
import 'package:blood_donation/features/services/google_places_api_service.dart';
import 'package:blood_donation/features/services/cloud_function_chat_service.dart';
import 'package:blood_donation/features/services/local_health_chat_service.dart';
import 'package:blood_donation/features/services/news_service.dart';
import 'package:blood_donation/features/services/openai_chat_service.dart';
import 'package:blood_donation/features/services/places_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDioProvider = Provider<Dio>((ref) {
  return DioClient().dio;
});

final newsServiceProvider = Provider<NewsService>((ref) {
  if (AppEnv.useMockServices) {
    return const MockNewsService();
  }
  if (AppEnv.hasNewsApi) {
    return ApiNewsService(ref.watch(appDioProvider));
  }
  return FirestoreNewsService(FirebaseFirestore.instance);
});

final chatServiceProvider = Provider<ChatService>((ref) {
  if (AppEnv.useMockServices) {
    return const MockChatService();
  }
  if (AppEnv.useCloudChat) {
    return CloudFunctionChatService();
  }
  if (AppEnv.allowClientOpenAi && AppEnv.hasOpenAi) {
    return OpenAiChatService(ref.watch(appDioProvider));
  }
  if (AppEnv.hasChatbotApi) {
    return ApiChatService(ref.watch(appDioProvider));
  }
  return const LocalHealthChatService();
});

final chatBackendLabelProvider = Provider<String>((ref) {
  if (AppEnv.useMockServices) {
    return 'Test mode';
  }
  if (AppEnv.useCloudChat) {
    return 'GitHub Models';
  }
  if (AppEnv.allowClientOpenAi && AppEnv.hasOpenAi) {
    return 'OpenAI (dev)';
  }
  if (AppEnv.hasChatbotApi) {
    return 'Custom API';
  }
  return 'Offline helper';
});

final placesServiceProvider = Provider<PlacesService>((ref) {
  if (AppEnv.useMockServices) {
    return const MockPlacesService();
  }
  if (AppEnv.hasGoogleMapsApi) {
    return GooglePlacesApiService(ref.watch(appDioProvider));
  }
  if (AppEnv.hasPlacesApi) {
    return ApiPlacesService(ref.watch(appDioProvider));
  }
  return FirestorePlacesService(FirebaseFirestore.instance);
});

final placesBackendLabelProvider = Provider<String>((ref) {
  if (AppEnv.useMockServices) {
    return 'Test mode';
  }
  if (AppEnv.hasGoogleMapsApi) {
    return 'Google Places';
  }
  if (AppEnv.hasPlacesApi) {
    return 'Custom API';
  }
  return 'Firestore centers';
});
