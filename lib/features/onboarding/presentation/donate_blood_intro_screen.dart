import 'dart:ui';

import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/core/storage/preferences_keys.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonateBloodIntroScreen extends StatefulWidget {
  const DonateBloodIntroScreen({super.key});

  @override
  State<DonateBloodIntroScreen> createState() => _DonateBloodIntroScreenState();
}

class _DonateBloodIntroScreenState extends State<DonateBloodIntroScreen> {
  final _pageController = PageController();

  static const _slides = [
    _IntroSlideData(
      title: 'Donate Blood',
      description:
          'A single donation can save multiple lives. Join a trusted network and be the reason someone gets another chance.',
      imagePath: 'assets/Donorr.png',
    ),
    _IntroSlideData(
      title: 'Save Lifes',
      description:
          'Get matched with urgent requests near you and respond quickly when hospitals and patients need support.',
      imagePath: 'assets/logo.png',
    ),
    _IntroSlideData(
      title: 'Get Connect Community',
      description:
          'Track your impact, stay informed, and be part of a caring donor community ready to help anytime.',
      imagePath: 'assets/recepint.png',
    ),
  ];

  int _currentPage = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeIntro() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferenceKeys.hasSeenDonateBloodIntro, true);

    if (!mounted) return;
    context.goNamed(AppRoutes.signIn.name);
  }

  Future<void> _nextOrFinish() async {
    if (_currentPage == _slides.length - 1) {
      await _completeIntro();
      return;
    }
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: _GlowOrb(
              size: 210,
              color: const Color(0xFFE53935).withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: _GlowOrb(
              size: 240,
              color: const Color(0xFF6AB6FF).withValues(alpha: 0.10),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isSubmitting ? null : _completeIntro,
                      child: Text(
                        'Skip',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        final slide = _slides[index];
                        return _IntroCard(slide: slide);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        height: 8,
                        width: index == _currentPage ? 22 : 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: index == _currentPage
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary
                                  .withValues(alpha: 0.30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _nextOrFinish,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        disabledBackgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _isSubmitting
                            ? 'Please wait...'
                            : isLast
                                ? 'Get Started'
                                : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.slide});

  final _IntroSlideData slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 540),
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: theme.colorScheme.surface.withValues(alpha: 0.80),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.40),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A2A395F),
                        blurRadius: 28,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 230,
                        height: 210,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: theme.colorScheme.surfaceContainerLowest
                              .withValues(alpha: 0.70),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          slide.imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        slide.description,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroSlideData {
  const _IntroSlideData({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  final String title;
  final String description;
  final String imagePath;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.02),
          ],
        ),
      ),
    );
  }
}
