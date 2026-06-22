import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.lastMessage,
    required this.updatedAt,
    required this.unreadCount,
  });

  final String id;
  final String peerId;
  final String peerName;
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadCount;
}

class DirectMessage {
  const DirectMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final bool isRead;
}

abstract class MessagingRepository {
  String conversationIdFor(String userA, String userB);

  Stream<List<ConversationSummary>> watchConversations(String userId);

  Stream<List<DirectMessage>> watchMessages({
    required String conversationId,
    required String currentUserId,
  });

  Future<void> sendMessage({
    required String senderId,
    required String recipientId,
    required String text,
    required String senderName,
    required String recipientName,
  });

  Future<void> markConversationRead({
    required String conversationId,
    required String currentUserId,
  });
}

class FirestoreMessagingRepository implements MessagingRepository {
  FirestoreMessagingRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  String conversationIdFor(String userA, String userB) {
    final ids = [userA, userB]..sort();
    return ids.join('_');
  }

  @override
  Stream<List<ConversationSummary>> watchConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final participants =
            (data['participantIds'] as List<dynamic>? ?? const []).cast<String>();
        final names = Map<String, String>.from(
          (data['participantNames'] as Map<String, dynamic>? ?? const {})
              .map((key, value) => MapEntry(key.toString(), value.toString())),
        );
        final peerId = participants.firstWhere(
          (id) => id != userId,
          orElse: () => '',
        );
        final unreadMap = Map<String, dynamic>.from(
          data['unreadCounts'] as Map<String, dynamic>? ?? const {},
        );
        return ConversationSummary(
          id: doc.id,
          peerId: peerId,
          peerName: names[peerId]?.trim().isNotEmpty == true
              ? names[peerId]!.trim()
              : 'User',
          lastMessage: (data['lastMessage'] ?? '').toString(),
          updatedAt: _asDateTime(data['updatedAt']) ?? DateTime.now(),
          unreadCount: (unreadMap[userId] as num?)?.toInt() ?? 0,
        );
      }).toList();
    });
  }

  @override
  Stream<List<DirectMessage>> watchMessages({
    required String conversationId,
    required String currentUserId,
  }) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DirectMessage(
          id: doc.id,
          senderId: (data['senderId'] ?? '').toString(),
          text: (data['text'] ?? '').toString(),
          createdAt: _asDateTime(data['createdAt']) ?? DateTime.now(),
          isRead: data['isRead'] == true || data['senderId'] == currentUserId,
        );
      }).toList();
    });
  }

  @override
  Future<void> sendMessage({
    required String senderId,
    required String recipientId,
    required String text,
    required String senderName,
    required String recipientName,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final conversationId = conversationIdFor(senderId, recipientId);
    final conversationRef =
        _firestore.collection('conversations').doc(conversationId);
    final messageRef = conversationRef.collection('messages').doc();

    await _firestore.runTransaction((transaction) async {
      final conversationSnap = await transaction.get(conversationRef);
      final now = FieldValue.serverTimestamp();

      transaction.set(messageRef, {
        'senderId': senderId,
        'text': trimmed,
        'createdAt': now,
        'isRead': false,
      });

      final unreadCounts = conversationSnap.exists
          ? Map<String, dynamic>.from(
              conversationSnap.data()?['unreadCounts'] as Map<String, dynamic>? ??
                  const {},
            )
          : <String, dynamic>{};

      unreadCounts[senderId] = 0;
      unreadCounts[recipientId] = ((unreadCounts[recipientId] as num?)?.toInt() ?? 0) + 1;

      transaction.set(
        conversationRef,
        {
          'participantIds': [senderId, recipientId],
          'participantNames': {
            senderId: senderName,
            recipientId: recipientName,
          },
          'lastMessage': trimmed,
          'updatedAt': now,
          'unreadCounts': unreadCounts,
        },
        SetOptions(merge: true),
      );
    });

    await _firestore
        .collection('users')
        .doc(recipientId)
        .collection('notifications')
        .add({
      'title': 'New message from $senderName',
      'body': trimmed,
      'type': 'message',
      'conversationId': conversationId,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  @override
  Future<void> markConversationRead({
    required String conversationId,
    required String currentUserId,
  }) async {
    final conversationRef =
        _firestore.collection('conversations').doc(conversationId);
    final messages = await conversationRef
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    batch.update(conversationRef, {
      'unreadCounts.$currentUserId': 0,
    });
    await batch.commit();
  }

  DateTime? _asDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return FirestoreMessagingRepository(FirebaseFirestore.instance);
});
