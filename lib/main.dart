import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
