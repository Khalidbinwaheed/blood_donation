import 'package:blood_donation/features/authentication/presentation/controllers/auth_view_model.dart';
import 'package:blood_donation/features/authentication/presentation/widgets/blood_group_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Pro-Tip: Location
// import 'package:geolocator/geolocator.dart'; // Add dependency if needed

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
  String? _selectedBloodGroup;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBloodGroup == null && _selectedRole != 'doctor') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your Blood Group')),
        );
        return;
      }

      // Pro-Tip: Request Location Permission immediately?
      // For now, we pass null, but we could add Geolocator logic here.
      double? lat, lng;

      final success = await ref.read(authViewModelProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            name: _nameController.text.trim(),
            bloodGroup: _selectedBloodGroup ?? 'N/A',
            role: _selectedRole,
            lat: lat,
            lng: lng,
          );

      if (!success && mounted) {
        final error = ref.read(authViewModelProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Signup Failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join the Lifesavers'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD32F2F),
                      ),
                ),
                const SizedBox(height: 24),

                // 1. Role Toggle
                Center(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'donor',
                        label: Text('Donor'),
                        icon: Icon(Icons.volunteer_activism),
                      ),
                      ButtonSegment(
                        value: 'recipient',
                        label: Text('Recipient'),
                        icon: Icon(Icons.bloodtype),
                      ),
                      ButtonSegment(
                        value: 'doctor',
                        label: Text('Doctor'),
                        icon: Icon(Icons.medical_services),
                      ),
                    ],
                    selected: {_selectedRole},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedRole = newSelection.first;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? Colors.red.shade100
                            : null,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? Colors.red.shade900
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Info Fields
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (val) => val == null || !val.contains('@')
                      ? 'Invalid email'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (val) =>
                      val == null || val.length < 6 ? 'min 6 characters' : null,
                ),
                const SizedBox(height: 32),

                // 3. Blood Group Selector (Horizontal)
                // Only show for Donor and Recipient
                if (_selectedRole != 'doctor') ...[
                  BloodGroupSelector(
                    selectedGroup: _selectedBloodGroup,
                    onSelected: (group) {
                      setState(() => _selectedBloodGroup = group);
                    },
                  ),
                  const SizedBox(height: 32),
                ],

                // 4. Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: authState.isLoading ? null : _handleSignup,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                    ),
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SIGN UP'),
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
