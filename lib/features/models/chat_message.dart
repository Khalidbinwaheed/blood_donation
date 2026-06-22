enum ChatRole { user, assistant, system }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.error,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime createdAt;
  final String? error;

  bool get hasError => (error ?? '').trim().isNotEmpty;

  ChatMessage copyWith({
    String? id,
    ChatRole? role,
    String? text,
    DateTime? createdAt,
    String? error,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'error': error,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
          .toString(),
      role: _parseRole((json['role'] ?? 'assistant').toString()),
      text: (json['text'] ?? json['message'] ?? '').toString(),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      error: json['error']?.toString(),
    );
  }

  static ChatRole _parseRole(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'user':
        return ChatRole.user;
      case 'system':
        return ChatRole.system;
      case 'assistant':
      default:
        return ChatRole.assistant;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.tryParse(value.toString());
  }
}
