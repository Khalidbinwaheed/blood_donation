import 'package:blood_donation/features/models/chat_message.dart';
import 'package:blood_donation/features/services/chat_service.dart';

/// Offline-capable health helper used when no external chatbot API is configured.
class LocalHealthChatService implements ChatService {
  const LocalHealthChatService();

  @override
  Future<ChatMessage> send({
    required String userId,
    required String message,
    required Map<String, dynamic> context,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final reply = _buildReply(message.trim().toLowerCase());

    return ChatMessage(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.assistant,
      text: reply,
      createdAt: DateTime.now(),
    );
  }

  String _buildReply(String message) {
    if (message.isEmpty) {
      return 'Ask me about blood donation eligibility, recovery, or emergency steps.';
    }

    if (_containsAny(message, ['eligib', 'donate', 'donor', 'can i give'])) {
      return 'Most healthy adults aged 18–65 who weigh at least 50 kg can donate blood. '
          'You should be feeling well, have no active infection, and avoid donation if you had '
          'surgery, tattoo, or piercing in the last 6 months. Use Donor Hub to update eligibility.';
    }

    if (_containsAny(message, ['after donate', 'recovery', 'rest', 'eat'])) {
      return 'After donating: rest 10–15 minutes, drink extra fluids for 24 hours, avoid heavy '
          'lifting for the rest of the day, and keep the bandage on for several hours. '
          'Contact a center if you feel dizzy or unwell.';
    }

    if (_containsAny(message, ['blood group', 'blood type', 'a+', 'b+', 'o+', 'ab'])) {
      return 'Blood groups determine compatibility. O- is the universal donor for red cells; '
          'AB+ can receive from all groups. Use Find Donors to search by blood group near you.';
    }

    if (_containsAny(message, ['emergency', 'urgent', 'sos', 'accident'])) {
      return 'For emergencies, use SOS/Ambulance in the app, call your local emergency number, '
          'or request blood through the Request Blood flow so nearby donors are notified.';
    }

    if (_containsAny(message, ['appointment', 'book', 'schedule'])) {
      return 'You can book a donation appointment from Appointments. Doctors set availability '
          'slots in advance; pick a center, doctor, and open time slot.';
    }

    if (_containsAny(message, ['pressure', 'bp', 'heart', 'pulse'])) {
      return 'Track vitals in Heart Monitor and BP Monitor. These readings are stored for your '
          'records and can be shared with your doctor during appointments.';
    }

    if (_containsAny(message, ['hi', 'hello', 'hey', 'salam', 'assalam'])) {
      return 'Hello! I am your Health Helper. I can guide you on blood donation, emergencies, '
          'appointments, and recovery. What would you like to know?';
    }

    return 'I can help with blood donation eligibility, post-donation care, finding donors, '
        'booking appointments, and emergency steps. Try asking about a specific topic.';
  }

  bool _containsAny(String message, List<String> terms) {
    return terms.any(message.contains);
  }
}
