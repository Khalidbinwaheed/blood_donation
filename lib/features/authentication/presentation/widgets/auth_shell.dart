import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    this.leading,
    this.trailing,
    this.illustrationAsset = 'assets/logo.png',
    this.illustrationTitle = 'Health Helper',
    this.illustrationSubtitle = 'Fast, safe, and private care assistance.',
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget? leading;
  final Widget? trailing;
  final String illustrationAsset;
  final String illustrationTitle;
  final String illustrationSubtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 28 : 16,
                      vertical: isWide ? 22 : 12,
                    ),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 5,
                                child: _AuthIllustrationCard(
                                  title: illustrationTitle,
                                  subtitle: illustrationSubtitle,
                                  assetPath: illustrationAsset,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 6,
                                child: _AuthFormCard(
                                  title: title,
                                  subtitle: subtitle,
                                  leading: leading,
                                  trailing: trailing,
                                  child: form,
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                _AuthIllustrationCard(
                                  title: illustrationTitle,
                                  subtitle: illustrationSubtitle,
                                  assetPath: illustrationAsset,
                                  compact: true,
                                ),
                                const SizedBox(height: 14),
                                _AuthFormCard(
                                  title: title,
                                  subtitle: subtitle,
                                  leading: leading,
                                  trailing: trailing,
                                  child: form,
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthIllustrationCard extends StatelessWidget {
  const _AuthIllustrationCard({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final String assetPath;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final illustration = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.14),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          semanticLabel: 'Health helper illustration',
          errorBuilder: (context, _, __) {
            return Icon(
              CupertinoIcons.photo_on_rectangle,
              size: 72,
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
            );
          },
        ),
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: Icon(
                CupertinoIcons.heart_fill,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.75,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: compact ? 220 : 360,
              child: illustration,
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthFormCard extends StatelessWidget {
  const _AuthFormCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.leading,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (leading != null) leading!,
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.74),
                  ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
