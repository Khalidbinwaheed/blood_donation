import 'package:blood_donation/core/services/analytics_service.dart';
import 'package:blood_donation/features/emergency/data/permission_providers.dart';
import 'package:blood_donation/features/settings/data/app_settings_provider.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyController {
  EmergencyController(this.ref);

  final Ref ref;

  String get ambulanceNumber => ref.read(appSettingsProvider).ambulanceNumber;

  Future<bool> callAmbulance() async {
    await ref.read(analyticsServiceProvider).logEvent('ambulance_called');
    final uri = Uri(scheme: 'tel', path: ambulanceNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }
    return false;
  }

  Future<bool> sendSmsToPrimaryContact(String? contact) async {
    if ((contact ?? '').trim().isEmpty) {
      return false;
    }
    final link = await buildMapsLink();
    if (link == null) {
      return false;
    }
    final smsUri = Uri(
      scheme: 'sms',
      path: contact,
      queryParameters: {
        'body': 'I need help at $link',
      },
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
      return true;
    }
    return false;
  }

  Future<bool> shareLiveLocation() async {
    final link = await buildMapsLink();
    if (link == null) {
      return false;
    }
    await SharePlus.instance.share(
      ShareParams(
        text: 'I need help. My live location: $link',
      ),
    );
    await ref.read(analyticsServiceProvider).logEvent('location_shared');
    return true;
  }

  Future<String?> buildMapsLink() async {
    final permissionController =
        ref.read(permissionControllerProvider.notifier);
    var permissionState =
        ref.read(permissionControllerProvider)[AppPermissionType.location];
    if (permissionState == null || !permissionState.granted) {
      permissionState =
          await permissionController.request(AppPermissionType.location);
      if (!permissionState.granted) {
        await ref
            .read(analyticsServiceProvider)
            .logEvent('permission_denied', parameters: {
          'permission': 'location',
        });
        return null;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    return 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
  }
}

final emergencyControllerProvider = Provider<EmergencyController>((ref) {
  return EmergencyController(ref);
});

final primaryContactProvider = Provider<String?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  final phone = user?.phoneNumber.trim();
  if ((phone ?? '').isEmpty) {
    return null;
  }
  return phone;
});

void showEmergencyActionSnack(
  BuildContext context, {
  required String text,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text)),
  );
}
