import 'package:blood_donation/features/authentication/presentation/controllers/auth_view_model.dart';
import 'package:blood_donation/features/authentication/presentation/widgets/pulse_logo.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Logic handled by AuthViewModel, routing by Router listening to AuthState
      final success = await ref.read(authViewModelProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      if (!success && mounted) {
        final error = ref.read(authViewModelProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Login Failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Vector (Abstract Wave)
          Positioned(
            bottom: -50,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/wave_bg.png', // Ensure this asset exists or use a generic one/container
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(100)),
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. The Pulse Logo
                    const PulseLogo(size: 100),
                    const SizedBox(height: 48),

                    // 2. Fields
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (val) => val == null || !val.contains('@')
                          ? 'Invalid email'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (val) => val == null || val.length < 6
                          ? 'min 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // 3. Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                          shadowColor: Colors.red.withValues(alpha: 0.4),
                        ),
                        child: authState.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'LOG IN',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 4. Social / Signup
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: TextStyle(color: Colors.grey[600])),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFFD32F2F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // 5. Emergency Skip
                    TextButton.icon(
                      onPressed: () {
                        // Navigate to home directly without auth
                        // Note: Ensure Firestore rules allow read-only access for guests
                        context.go('/home');
                      },
                      icon:
                          const Icon(Icons.local_hospital, color: Colors.grey),
                      label: const Text('Skip Login (Browse Requests)',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
