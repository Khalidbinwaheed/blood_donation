import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/authentication/presentation/controllers/auth_view_model.dart';
import 'package:blood_donation/features/authentication/presentation/widgets/auth_shell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authViewModelProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

    if (!success && mounted) {
      final error = ref.read(authViewModelProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Login failed')),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    final success =
        await ref.read(authViewModelProvider.notifier).signInWithGoogle();

    if (!success && mounted) {
      final error = ref.read(authViewModelProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Google sign-in failed')),
      );
    }
  }

  Future<void> _handleBiometricLogin() async {
    final success =
        await ref.read(authViewModelProvider.notifier).signInWithBiometrics();

    if (!success && mounted) {
      final error = ref.read(authViewModelProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Biometric sign-in failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final theme = Theme.of(context);

    return AuthShell(
      title: 'Welcome back',
      subtitle: 'Sign in to continue with chat, SOS, hospitals, and records.',
      trailing: TextButton(
        onPressed: () => context.goNamed(AppRoutes.home.name),
        child: const Text('Skip'),
      ),
      illustrationAsset: 'assets/Donorr.png',
      illustrationTitle: 'Stay ready to help',
      illustrationSubtitle:
          'Track requests and respond fast with a clean, safe workflow.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                context,
                'Email address',
                icon: CupertinoIcons.mail_solid,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
              decoration: _inputDecoration(
                context,
                'Password',
                icon: CupertinoIcons.lock_fill,
              ).copyWith(
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? CupertinoIcons.eye
                        : CupertinoIcons.eye_slash,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    context.pushNamed(AppRoutes.forgotPassword.name),
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: 6),
            FilledButton(
              onPressed: authState.isLoading ? null : _handleLogin,
              child: authState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign in'),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'or continue with',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: authState.isLoading ? null : _handleGoogleLogin,
                    icon: const Icon(
                      Icons.g_mobiledata,
                      color: Color(0xFFEA4335),
                      size: 26,
                    ),
                    label: const Text('Google'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        authState.isLoading ? null : _handleBiometricLogin,
                    icon:
                        const Icon(Icons.fingerprint, color: Color(0xFF0A84FF)),
                    label: const Text('Biometric'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () => context.pushNamed(AppRoutes.register.name),
                  child: const Text('Create account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(
  BuildContext context,
  String hint, {
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    ),
  );
}
