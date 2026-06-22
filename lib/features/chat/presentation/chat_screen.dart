import 'package:blood_donation/features/chat/presentation/chat_controller.dart';
import 'package:blood_donation/features/services/service_providers.dart';
import 'package:blood_donation/features/models/chat_message.dart';
import 'package:blood_donation/features/widgets/typing_indicator.dart';
import 'package:blood_donation/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final backendLabel = ref.watch(chatBackendLabelProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask Health Helper'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(18),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Powered by $backendLabel',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Inbox',
            onPressed: () => context.pushNamed(AppRoutes.inbox.name),
            icon: const Icon(Icons.inbox_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: chatState.messages.isEmpty
                  ? const Center(
                      child: Text('Ask your first question'),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(14),
                      itemCount: chatState.messages.length +
                          (chatState.isSending ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (chatState.isSending &&
                            index == chatState.messages.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TypingIndicator(),
                            ),
                          );
                        }

                        final message = chatState.messages[index];
                        return _MessageBubble(message: message);
                      },
                    ),
            ),
            if ((chatState.errorMessage ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Could not send or receive message.'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(chatControllerProvider.notifier).retryLast();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      textInputAction: TextInputAction.send,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Type your health question...',
                        prefixIcon: Icon(Icons.mic_none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: chatState.isSending ? null : _send,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = _inputController.text;
    _inputController.clear();
    ref.read(chatControllerProvider.notifier).sendMessage(text);
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final bubbleColor = isUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor =
        isUser ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Card(
          color: bubbleColor,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(color: textColor),
                ),
                if (message.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Tap retry to send again.',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
