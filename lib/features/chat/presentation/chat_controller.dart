import 'dart:async';

import 'package:blood_donation/core/services/analytics_service.dart';
import 'package:blood_donation/core/storage/cache_boxes.dart';
import 'package:blood_donation/features/models/chat_message.dart';
import 'package:blood_donation/features/services/chat_service.dart';
import 'package:blood_donation/features/services/service_providers.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class ChatState {
  const ChatState({
    required this.messages,
    required this.isSending,
    required this.errorMessage,
  });

  factory ChatState.initial() {
    return const ChatState(
      messages: [],
      isSending: false,
      errorMessage: null,
    );
  }

  final List<ChatMessage> messages;
  final bool isSending;
  final String? errorMessage;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  ChatController({
    required this.chatService,
    required this.analyticsService,
    required this.userRead,
    required this.cacheBox,
  }) : super(ChatState.initial()) {
    _loadCachedHistory();
  }

  final ChatService chatService;
  final AnalyticsService analyticsService;
  final String Function() userRead;
  final Box<dynamic> cacheBox;

  DateTime? _lastSendAt;

  Future<void> sendMessage(String rawMessage) async {
    final message = rawMessage.trim();
    if (message.isEmpty) {
      return;
    }
    if (_lastSendAt != null &&
        DateTime.now().difference(_lastSendAt!).inMilliseconds < 900) {
      return;
    }
    _lastSendAt = DateTime.now();

    final userMsg = ChatMessage(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.user,
      text: message,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
      clearError: true,
    );

    await analyticsService.logEvent('chatbot_message_sent');

    try {
      final response = await chatService.send(
        userId: userRead(),
        message: message,
        context: {
          'history': state.messages
              .take(6)
              .map((e) => {'role': e.role.name, 'text': e.text})
              .toList(),
        },
      );
      state = state.copyWith(
        messages: [...state.messages, response],
        isSending: false,
      );
      await _persistHistory();
    } catch (_) {
      final errorMsg = ChatMessage(
        id: 'e_${DateTime.now().microsecondsSinceEpoch}',
        role: ChatRole.assistant,
        text: 'I could not reach Health Helper right now. Tap retry.',
        createdAt: DateTime.now(),
        error: 'request_failed',
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isSending: false,
        errorMessage: 'Request failed',
      );
      await analyticsService.logEvent('error_shown', parameters: {
        'feature': 'chat',
      });
      await _persistHistory();
    }
  }

  Future<void> retryLast() async {
    final latestUser = state.messages.lastWhere(
      (msg) => msg.role == ChatRole.user,
      orElse: () => ChatMessage(
        id: '',
        role: ChatRole.system,
        text: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    if (latestUser.text.isNotEmpty) {
      await sendMessage(latestUser.text);
    }
  }

  List<ChatMessage> previewMessages() {
    final reversed = state.messages.reversed.toList();
    final top = reversed.take(3).toList();
    return top.reversed.toList();
  }

  void _loadCachedHistory() {
    final raw = cacheBox.get('chat_history');
    if (raw is List) {
      final messages = raw
          .whereType<Map>()
          .map((json) => ChatMessage.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      state = state.copyWith(messages: messages);
    }
  }

  Future<void> _persistHistory() async {
    await cacheBox.put(
      'chat_history',
      state.messages.take(40).map((message) => message.toJson()).toList(),
    );
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final box = Hive.box<dynamic>(CacheBoxes.chat);
  return ChatController(
    chatService: ref.watch(chatServiceProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
    userRead: () => ref.read(currentUserProvider).value?.uid ?? 'guest',
    cacheBox: box,
  );
});
