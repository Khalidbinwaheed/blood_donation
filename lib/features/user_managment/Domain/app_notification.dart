class AppNotification {
  final String text;
  final String date;
  final String donorId;
  final String recipientId;

  const AppNotification({
    required this.text,
    required this.date,
    required this.donorId,
    required this.recipientId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppNotification &&
          runtimeType == other.runtimeType &&
          other.text == text &&
          other.date == date &&
          other.donorId == donorId &&
          other.recipientId == recipientId);
  @override
  int get hashCode =>
      text.hashCode ^ date.hashCode ^ donorId.hashCode ^ recipientId.hashCode;

  @override
  String toString() {
    return 'AppNotification{text: $text, date: $date, donorId: $donorId, recipientId: $recipientId}';
  }

  AppNotification copyWith({
    String? text,
    String? date,
    String? donorId,
    String? recipientId,
  }) {
    return AppNotification(
      text: text ?? this.text,
      date: date ?? this.date,
      donorId: donorId ?? this.donorId,
      recipientId: recipientId ?? this.recipientId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'date': date,
      'donorId': donorId,
      'recipientId': recipientId,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      text: map['text'] ?? '',
      date: map['date'] ?? '',
      donorId: map['donorId'] ?? '',
      recipientId: map['recipientId'] ?? '',
    );
  }
}
