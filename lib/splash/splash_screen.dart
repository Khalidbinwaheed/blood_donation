import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/core/storage/preferences_keys.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static bool _shownThisSession = false;

  late AnimationController _controller;
  late Animation<Offset> _logoAnimatin;
  late Animation<Offset> _textAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _logoAnimatin = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _textAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (_shownThisSession) {
      _navigateAfterSplash(skipDelay: true);
      return;
    }

    _shownThisSession = true;
    _controller.forward();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash({bool skipDelay = false}) async {
    if (!skipDelay) {
      await Future<void>.delayed(const Duration(seconds: 5));
    }
    final prefs = await SharedPreferences.getInstance();
    final hasSeenIntro =
        prefs.getBool(PreferenceKeys.hasSeenDonateBloodIntro) ?? false;

    if (!mounted) return;

    if (hasSeenIntro) {
      context.goNamed(AppRoutes.home.name);
      return;
    }
    context.goNamed(AppRoutes.onboarding.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1F);
    final subtitleColor =
        isDark ? Colors.white.withValues(alpha: 0.78) : const Color(0xFF5D5D67);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF0B0D12),
                    Color(0xFF161B25),
                    Color(0xFF2A1010)
                  ]
                : const [
                    Color(0xFFFFF7F4),
                    Color(0xFFFBE9E7),
                    Color(0xFFF2F2F7)
                  ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SlideTransition(
                  position: _logoAnimatin,
                  child: Container(
                    width: 168,
                    height: 168,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.72),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.28 : 0.08),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 26),
                SlideTransition(
                  position: _textAnimation,
                  child: Text(
                    'Lifeline',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SlideTransition(
                  position: _textAnimation,
                  child: Text(
                    'Blood donation and emergency care in one place',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: subtitleColor,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
