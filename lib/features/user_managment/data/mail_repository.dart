import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

part 'mail_repository.g.dart';

class Mailrepository {
  Future<void> sendEmail(
      {required String donorEmail,
      required String recipientEmail,
      required String recipientName,
      required String recipientPhone,
      required String recipientBloodGroup}) async {
    const String username = 'Blooddonationkp@gmail.com';
    const String password = '';

    final SmtpServer = gmail(username, password);
    final message = Message()
      ..from = const Address(username, 'Blood Donation App')
      ..recipients.add(donorEmail)
      ..subject = 'Blood Donation Request from $recipientName'
      ..text = 'Hello, $donorEmail\n\n'
          'You have received a blood donation request from $recipientName.\n'
          'Name: $recipientName\n'
          'Phone: $recipientPhone\n'
          'Email: $recipientEmail\n'
          'Blood Group: $recipientBloodGroup\n\n'
          'Please contact them if you are willing to donate blood.\n\n'
          'Thank you!'
      ..html = '<p>Hello, $donorEmail</p>'
          '<p>You have received a blood donation request from $recipientName.</p>'
          '<p>Name: $recipientName</p>'
          '<p>Phone: $recipientPhone</p>'
          '<p>Email: $recipientEmail</p>'
          '<p>Blood Group: $recipientBloodGroup</p>'
          '<p>Please contact them if you are willing to donate blood.</p>'
          '<p>Thank you!</p>';
    try {
      await send(message, SmtpServer);
    } on MailerException catch (e) {
      throw Exception('Failed to send email: ${e.message}');
    }
  }
}

@riverpod
Mailrepository mailRepository(MailrepositoryRef ref) {
  return Mailrepository();
}
