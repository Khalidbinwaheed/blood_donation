import 'package:blood_donation/firebase_options.dart';
import 'package:blood_donation/routes/routes.dart';
import 'package:blood_donation/util/appstyles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    runApp(const ConfigurationErrorApp(error: "Firebase Initialization Failed"));
  }
}

class ConfigurationErrorApp extends StatelessWidget {
  final String error;
  const ConfigurationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'Configuration Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'The application could not start because Firebase is not configured correctly for this platform.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),
                const Text(
                  'To fix this:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Run "flutterfire configure" in your terminal to set up Firebase for Web.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Technical Details: $error',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(goRouterProvider),
      debugShowCheckedModeBanner: false,
      title: 'Blood Donation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppStyle.mainColor),
        useMaterial3: true,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: AppStyle.mainColor,
          centerTitle: true,
          iconTheme: IconThemeData().copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
