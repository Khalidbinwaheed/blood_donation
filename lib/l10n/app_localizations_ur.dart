// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'کیئر لنک';

  @override
  String homeGreeting(String firstName) {
    return 'مرحبا، $firstName';
  }

  @override
  String lastCheckIn(String date) {
    return 'آخری چیک ان: $date';
  }

  @override
  String get donorCtaTitle => 'میں ڈونر ہوں';

  @override
  String get donorCtaSubtitle => 'آج ہی زندگی بچائیں';

  @override
  String get recipientCtaTitle => 'میں وصول کنندہ ہوں';

  @override
  String get recipientCtaSubtitle => 'میچ تلاش کریں';

  @override
  String get quickActionsTitle => 'فوری اقدامات';

  @override
  String get nearbyCentersTitle => 'قریبی مراکز';

  @override
  String get openNow => 'ابھی کھلا ہے';

  @override
  String get call => 'کال کریں';

  @override
  String get directions => 'راستہ';

  @override
  String get newsTitle => 'صحت کی خبریں';

  @override
  String get requestHelp => 'مدد کی درخواست';

  @override
  String get bookAppointment => 'اپائنٹمنٹ بک کریں';

  @override
  String get myId => 'میری شناخت/QR';

  @override
  String get emergencySos => 'ہنگامی SOS';
}
