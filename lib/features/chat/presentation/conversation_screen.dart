import 'package:blood_donation/features/chat/data/messaging_repository.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({
    required this.peerId,
    required this.peerName,
    super.key,
  });

  final String peerId;
  final String peerName;

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in to chat.')),
      );
    }

    final repository = ref.watch(messagingRepositoryProvider);
    final conversationId =
        repository.conversationIdFor(user.uid, widget.peerId);
    final messagesStream = repository.watchMessages(
      conversationId: conversationId,
      currentUserId: user.uid,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      repository.markConversationRead(
        conversationId: conversationId,
        currentUserId: user.uid,
      );
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<DirectMessage>>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? const [];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Start the conversation'),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(14),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = message.senderId == user.uid;
                    return Align(
                      alignment:
                          isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: isMine
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isMine
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    textInputAction: TextInputAction.send,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => _send(user.uid, user),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed:
                      _isSending ? null : () => _send(user.uid, user),
                  child: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send(String senderId, dynamic user) async {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final senderName =
        '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim().ifEmpty('User');

    setState(() => _isSending = true);
    _inputController.clear();
    try {
      await ref.read(messagingRepositoryProvider).sendMessage(
            senderId: senderId,
            recipientId: widget.peerId,
            text: text,
            senderName: senderName,
            recipientName: widget.peerName,
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send message: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
