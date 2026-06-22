import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  static const _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  static const _genders = ['Male', 'Female', 'Other'];

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _aboutController = TextEditingController();

  int _step = 0;
  String _bloodGroup = 'A+';
  DateTime? _dob;
  String? _gender;
  bool _wantsToDonate = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
      _nameController.text = fullName;
      _phoneController.text = user.phoneNumber;
      _countryController.text = 'Pakistan';
      _cityController.text = user.district;
      if (user.bloodGroup.trim().isNotEmpty) {
        _bloodGroup = user.bloodGroup.trim().toUpperCase();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastStep = _step == 2;
    final stepTitle = switch (_step) {
      0 => 'Personal Information',
      1 => 'Basic Information',
      _ => 'Upload Your Image',
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profile Setup'),
        actions: [
          TextButton(
            onPressed: () => context.goNamed(AppRoutes.home.name),
            child: const Text('Skip'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "It's optional. You can fill it out now or later.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.72),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _StepProgress(step: _step),
                      const SizedBox(height: 14),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.14),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      _step == 2
                                          ? CupertinoIcons.photo
                                          : CupertinoIcons.person,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      stepTitle,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  if (_step == 1)
                                    Text(
                                      _ageLabel(),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: switch (_step) {
                                  0 => _buildPersonalStep(context),
                                  1 => _buildBasicStep(context),
                                  _ => _buildUploadStep(context),
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                if (isLastStep) {
                                  _submit();
                                  return;
                                }
                                if (_canContinue()) {
                                  setState(() => _step += 1);
                                } else {
                                  _showValidationMessage();
                                }
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: _canContinue() || isLastStep
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary
                                  .withValues(alpha: 0.35),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(isLastStep ? 'Home' : 'Next'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPersonalStep(BuildContext context) {
    return Column(
      key: const ValueKey('personal-step'),
      children: [
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration('Your Name'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration('Mobile Number'),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _bloodGroup,
          decoration: _inputDecoration('Select Group'),
          items: _bloodGroups
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _bloodGroup = value);
            }
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _countryController,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration('Country'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _cityController,
          textInputAction: TextInputAction.done,
          decoration: _inputDecoration('City'),
        ),
      ],
    );
  }

  Widget _buildBasicStep(BuildContext context) {
    return Column(
      key: const ValueKey('basic-step'),
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: _dob ?? DateTime(now.year - 20, now.month, now.day),
              firstDate: DateTime(now.year - 90),
              lastDate: now,
            );
            if (picked != null) {
              setState(() => _dob = picked);
            }
          },
          child: InputDecorator(
            decoration: _inputDecoration('Date of Birth'),
            child: Row(
              children: [
                Text(_dob == null
                    ? 'Select date'
                    : DateFormat('dd MMM yyyy').format(_dob!)),
                const Spacer(),
                const Icon(CupertinoIcons.calendar),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _gender,
          decoration: _inputDecoration('Gender'),
          items: _genders
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _gender = value),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<bool>(
          initialValue: _wantsToDonate,
          decoration: _inputDecoration('I Want to donate blood'),
          items: const [
            DropdownMenuItem(value: true, child: Text('Yes')),
            DropdownMenuItem(value: false, child: Text('No')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _wantsToDonate = value);
            }
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _aboutController,
          maxLines: 4,
          decoration: _inputDecoration('About yourself'),
        ),
      ],
    );
  }

  Widget _buildUploadStep(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('upload-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              style: BorderStyle.solid,
            ),
            color: theme.colorScheme.surfaceContainerLowest,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Image upload hook is ready for integration.')),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo,
                    color: theme.colorScheme.primary, size: 30),
                const SizedBox(height: 10),
                Text(
                  'Upload your profile photo',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to connect gallery/camera',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'You can update your photo later in Profile settings.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  bool _canContinue() {
    if (_step == 0) {
      return _nameController.text.trim().isNotEmpty &&
          _phoneController.text.trim().isNotEmpty &&
          _countryController.text.trim().isNotEmpty &&
          _cityController.text.trim().isNotEmpty;
    }
    if (_step == 1) {
      return _dob != null && (_gender?.trim().isNotEmpty ?? false);
    }
    return true;
  }

  void _showValidationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Please complete the required fields first.')),
    );
  }

  String _ageLabel() {
    if (_dob == null) {
      return 'Your age - 0';
    }
    final age = DateTime.now().difference(_dob!).inDays ~/ 365;
    return 'Your age - $age';
  }

  Future<void> _submit() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) {
      if (mounted) {
        context.goNamed(AppRoutes.signIn.name);
      }
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final fullName = _nameController.text.trim();
      final parts =
          fullName.split(' ').where((s) => s.trim().isNotEmpty).toList();
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.skip(1).join(' ') : '';

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': _phoneController.text.trim(),
        'bloodGroup': _bloodGroup,
        'country': _countryController.text.trim(),
        'district': _cityController.text.trim(),
        'gender': _gender ?? '',
        'dateOfBirth': _dob?.toIso8601String(),
        'wantsToDonate': _wantsToDonate,
        'about': _aboutController.text.trim(),
        'profileCompletedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile setup complete.')),
        );
        context.goNamed(AppRoutes.home.name);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save profile right now.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(3, (index) {
        final active = index <= step;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: active
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
        );
      }),
    );
  }
}
