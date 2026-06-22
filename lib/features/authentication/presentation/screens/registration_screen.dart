import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/authentication/presentation/controllers/auth_view_model.dart';
import 'package:blood_donation/features/authentication/presentation/widgets/auth_shell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedRole = 'donor';
  String? _selectedBloodGroup = 'A+';
  bool _obscurePassword = true;

  static const List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final role = GoRouterState.of(context).uri.queryParameters['role'];
    if (role == 'donor' || role == 'recipient') {
      _selectedRole = role!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select blood group')),
      );
      return;
    }

    final success = await ref.read(authViewModelProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          bloodGroup: _selectedBloodGroup!,
          role: _selectedRole,
        );

    if (!success && mounted) {
      final error = ref.read(authViewModelProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Signup failed')),
      );
      return;
    }

    if (success && mounted) {
      context.goNamed(AppRoutes.profileSetup.name);
    }
  }

  Future<void> _handleGoogleSignup() async {
    final success =
        await ref.read(authViewModelProvider.notifier).signInWithGoogle();

    if (!success && mounted) {
      final error = ref.read(authViewModelProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Google sign-in failed')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final theme = Theme.of(context);

    return AuthShell(
      title: 'Create account',
      subtitle:
          'Join as donor or recipient and complete setup in a few simple steps.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => context.pop(),
        icon: const Icon(CupertinoIcons.back),
      ),
      illustrationAsset: 'assets/recepint.png',
      illustrationTitle: 'Profile setup made easy',
      illustrationSubtitle:
          'Your information helps us route emergency blood matches faster.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _RoleChip(
                    title: 'Donor',
                    selected: _selectedRole == 'donor',
                    onTap: () => setState(() => _selectedRole = 'donor'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _RoleChip(
                    title: 'Recipient',
                    selected: _selectedRole == 'recipient',
                    onTap: () => setState(() => _selectedRole = 'recipient'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                context,
                'Full name',
                icon: CupertinoIcons.person_fill,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
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
              textInputAction: TextInputAction.next,
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
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedBloodGroup,
              decoration: _inputDecoration(
                context,
                'Blood Group',
                icon: CupertinoIcons.drop_fill,
              ),
              items: _bloodGroups
                  .map(
                    (group) => DropdownMenuItem<String>(
                      value: group,
                      child: Text(group),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedBloodGroup = value);
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: authState.isLoading ? null : _handleSignup,
              child: authState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create account'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: authState.isLoading ? null : _handleGoogleSignup,
              icon: const Icon(
                Icons.g_mobiledata,
                color: Color(0xFFEA4335),
                size: 26,
              ),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () => context.goNamed(AppRoutes.signIn.name),
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackground = theme.colorScheme.surface;
    final selectedColor = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.12)
              : defaultBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? selectedColor
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? selectedColor
                : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
            fontWeight: FontWeight.w600,
          ),
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
