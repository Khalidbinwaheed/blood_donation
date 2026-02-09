// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CareLink';

  @override
  String homeGreeting(String firstName) {
    return 'Hi, $firstName';
  }

  @override
  String lastCheckIn(String date) {
    return 'Last check-in: $date';
  }

  @override
  String get donorCtaTitle => 'I\'m a Donor';

  @override
  String get donorCtaSubtitle => 'Give life today';

  @override
  String get recipientCtaTitle => 'I\'m a Recipient';

  @override
  String get recipientCtaSubtitle => 'Find a match';

  @override
  String get quickActionsTitle => 'Quick Actions';

  @override
  String get nearbyCentersTitle => 'Nearby Centers';

  @override
  String get openNow => 'Open Now';

  @override
  String get call => 'Call';

  @override
  String get directions => 'Directions';

  @override
  String get newsTitle => 'Health News';

  @override
  String get requestHelp => 'Request Help';

  @override
  String get bookAppointment => 'Book Appointment';

  @override
  String get myId => 'My ID/QR';

  @override
  String get emergencySos => 'Emergency SOS';
}
