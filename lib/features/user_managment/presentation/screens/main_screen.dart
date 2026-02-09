import 'package:blood_donation/core/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CareLinkApp extends ConsumerWidget {
  const CareLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    // Use AppTheme provided previously
    return MaterialApp.router(
      routerConfig: router,
      title: 'CareLink',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.red,
      ),
    );
  }
}
