import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

enum AppPermissionType {
  location,
  phone,
  sms,
  notifications,
}

class PermissionState {
  const PermissionState({
    required this.type,
    required this.status,
  });

  final AppPermissionType type;
  final PermissionStatus status;

  bool get granted => status.isGranted;
  bool get deniedPermanently => status.isPermanentlyDenied;
}

class PermissionController
    extends StateNotifier<Map<AppPermissionType, PermissionState>> {
  PermissionController()
      : super({
          for (final type in AppPermissionType.values)
            type: PermissionState(type: type, status: PermissionStatus.denied),
        });

  Future<void> refreshAll() async {
    final next = <AppPermissionType, PermissionState>{};
    for (final type in AppPermissionType.values) {
      final status = await _permissionFor(type).status;
      next[type] = PermissionState(type: type, status: status);
    }
    state = next;
  }

  Future<PermissionState> request(AppPermissionType type) async {
    final status = await _permissionFor(type).request();
    final nextState = PermissionState(type: type, status: status);
    state = {
      ...state,
      type: nextState,
    };
    return nextState;
  }

  Future<void> openSystemSettings() async {
    await openAppSettings();
  }

  Permission _permissionFor(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.location:
        return Permission.locationWhenInUse;
      case AppPermissionType.phone:
        return Permission.phone;
      case AppPermissionType.sms:
        return Permission.sms;
      case AppPermissionType.notifications:
        return Permission.notification;
    }
  }
}

final permissionControllerProvider = StateNotifierProvider<PermissionController,
    Map<AppPermissionType, PermissionState>>(
  (ref) {
    final controller = PermissionController();
    controller.refreshAll();
    return controller;
  },
);
