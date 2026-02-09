import 'package:blood_donation/core/router/router.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:blood_donation/l10n/app_localizations.dart'; // Generated in lib/l10n/
import 'package:blood_donation/core/services/notification_service.dart';
import 'core/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload SharedPreferences for robust theme handling
  final prefs = await SharedPreferences.getInstance();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(ProviderScope(
      overrides: [
        themeServiceProvider.overrideWith((ref) => ThemeNotifier(prefs)),
      ],
      child: const CareLinkApp(),
    ));
  } catch (e) {
    runApp(ConfigurationErrorApp(error: e.toString()));
  }
}

class CareLinkApp extends ConsumerStatefulWidget {
  const CareLinkApp({super.key});

  @override
  ConsumerState<CareLinkApp> createState() => _CareLinkAppState();
}

class _CareLinkAppState extends ConsumerState<CareLinkApp> {
  @override
  void initState() {
    super.initState();
    // Initialize notification service
    // Using addPostFrameCallback to ensure provider is ready if needed, though usually safe here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).init(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeServiceProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'CareLink',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ur'), // Urdu
      ],
    );
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
                  'Initialization Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Firebase failed to initialize.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),
                Text(
                  'Error: $error',
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
