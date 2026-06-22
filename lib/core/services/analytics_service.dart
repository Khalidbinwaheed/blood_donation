import 'package:blood_donation/core/config/app_env.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AnalyticsService {
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  });
}

class NoOpAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {}
}

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    final sanitized = <String, Object>{};
    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }
      if (value is String || value is num) {
        sanitized[entry.key] = value;
      } else {
        sanitized[entry.key] = value.toString();
      }
    }

    await _analytics.logEvent(name: name, parameters: sanitized);
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  if (AppEnv.useMockServices) {
    return NoOpAnalyticsService();
  }
  return FirebaseAnalyticsService(FirebaseAnalytics.instance);
});
