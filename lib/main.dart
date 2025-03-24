import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ,
      debugShowCheckedModeBanner: false,
      title: 'Blood Donation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff680c07)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme().copyWith(
          color: const Color(0xff680c07),
          centerTitle: true,
          iconTheme: IconThemeData().copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
