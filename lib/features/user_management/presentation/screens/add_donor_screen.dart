import 'package:blood_donation/common_widgets/async_value_ui.dart';
import 'package:blood_donation/common_widgets/common_button.dart';
import 'package:blood_donation/common_widgets/common_text_field.dart';
import 'package:blood_donation/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:blood_donation/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddDonorScreen extends ConsumerStatefulWidget {
  const AddDonorScreen({super.key});

  @override
  ConsumerState<AddDonorScreen> createState() => _AddDonorScreenState();
}

class _AddDonorScreenState extends ConsumerState<AddDonorScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _districtController = TextEditingController(); // Added District
  String _selectedBloodGroup = 'A+'; // Default

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final state = ref.watch(authControllerProvider);

    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (!state.isLoading && !state.hasError) {
        // Success! Go back to main screen or show success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Donor added successfully!'),
          backgroundColor: Colors.green,
        ));
        context.pop();
      }
      state.showAlertDialogOnError(context);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Donor'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                CommonTextField(
                  hintText: 'Full Name',
                  textInputType: TextInputType.name,
                  controller: _nameController,
                ),
                const SizedBox(height: 15),
                CommonTextField(
                  hintText: 'Email Address',
                  textInputType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                const SizedBox(height: 15),
                CommonTextField(
                  hintText: 'Password',
                  textInputType: TextInputType.visiblePassword,
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                CommonTextField(
                  hintText: 'Phone Number',
                  textInputType: TextInputType.phone,
                  controller: _phoneController,
                ),
                const SizedBox(height: 15),
                CommonTextField(
                  hintText: 'District',
                  textInputType: TextInputType.text,
                  controller: _districtController,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBloodGroup,
                  decoration: const InputDecoration(
                    labelText: 'Blood Group',
                  ),
                  items: _bloodGroups.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedBloodGroup = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 30),
                CommonButton(
                  onTap: () {
                    ref
                        .read(authControllerProvider.notifier)
                        .createUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                          name: _nameController.text,
                          phoneNumber: _phoneController.text,
                          bloodGroup: _selectedBloodGroup,
                          type: 'donor',
                          district: _districtController.text,
                        );
                  },
                  title: 'Add Donor',
                  isLoading: state.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
