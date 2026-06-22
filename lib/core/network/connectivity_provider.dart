import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();
  final controller = StreamController<bool>();

  Future<void> emitCurrent() async {
    final results = await connectivity.checkConnectivity();
    final online = _isOnline(results);
    controller.add(online);
  }

  final subscription = connectivity.onConnectivityChanged.listen((results) {
    controller.add(_isOnline(results));
  });

  emitCurrent();
  ref.onDispose(() async {
    await subscription.cancel();
    await controller.close();
  });

  return controller.stream.distinct();
});

bool _isOnline(List<ConnectivityResult> results) {
  return results.any((result) => result != ConnectivityResult.none);
}
