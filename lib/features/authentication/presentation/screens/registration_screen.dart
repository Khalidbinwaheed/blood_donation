import 'package:blood_donation/common_widgets/async_value_ui.dart';
import 'package:blood_donation/common_widgets/common_button.dart';
import 'package:blood_donation/common_widgets/common_text_field.dart';
import 'package:blood_donation/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:blood_donation/routes/routes.dart';
import 'package:blood_donation/util/appstyles.dart';
import 'package:blood_donation/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen(this.type, {super.key});

  final String type;

  @override
  ConsumerState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _districtcontroller = TextEditingController();

  String? _selectedBloodGroup;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final state = ref.watch(authControllerProvider);

    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      state.showAlertDialogOnError(context);
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Header with Gradient
          Container(
            height: SizeConfig.screenHeight * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppStyle.primaryColor,
                  AppStyle.secondaryColor,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      height: SizeConfig.getProportionateHeight(60),
                      width: SizeConfig.getProportionateWidth(60),
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Create Account',
                    style: AppStyle.headingTextStyle.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                  Text(
                    'Join the community of heroes',
                    style: AppStyle.normalTextStyle.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: SizeConfig.screenHeight * 0.28),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.type} Registration',
                          style: AppStyle.titleTextStyle.copyWith(fontSize: 22),
                        ),
                        SizedBox(height: SizeConfig.getProportionateHeight(25)),
                        CommonTextField(
                          hintText: 'Full Name',
                          textInputType: TextInputType.text,
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.person_outline,
                              color: Colors.grey),
                          filled: true,
                          fillColor: AppStyle.backgroundColor,
                        ),
                        SizedBox(height: SizeConfig.getProportionateHeight(15)),
                        CommonTextField(
                          hintText: 'Email Address',
                          textInputType: TextInputType.emailAddress,
                          controller: _emailController,
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: Colors.grey),
                          filled: true,
                          fillColor: AppStyle.backgroundColor,
                        ),
                        SizedBox(height: SizeConfig.getProportionateHeight(15)),
                        CommonTextField(
                          hintText: 'Password',
                          textInputType: TextInputType.visiblePassword,
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.grey),
                          filled: true,
                          fillColor: AppStyle.backgroundColor,
                        ),
                        SizedBox(height: SizeConfig.getProportionateHeight(15)),
                        CommonTextField(
                          hintText: 'Phone Number',
                          textInputType: TextInputType.phone,
                          controller: _phoneNumberController,
                          prefixIcon: const Icon(Icons.phone_outlined,
                              color: Colors.grey),
                          filled: true,
                          fillColor: AppStyle.backgroundColor,
                        ),
                        SizedBox(height: SizeConfig.getProportionateHeight(15)),
                        CommonTextField(
                          hintText: 'District',
                          textInputType: TextInputType.text,
                          controller: _districtcontroller,
                          prefixIcon: const Icon(Icons.location_on_outlined,
                              color: Colors.grey),
                          filled: true,
                          fillColor: AppStyle.backgroundColor,
                        ),
                        SizedBox(height: SizeConfig.getProportionateHeight(15)),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedBloodGroup,
                          decoration: InputDecoration(
                            labelText: 'Select Blood Group',
                            labelStyle: TextStyle(color: Colors.grey.shade700),
                            prefixIcon: const Icon(Icons.bloodtype_outlined,
                                color: Colors.grey),
                            filled: true,
                            fillColor: AppStyle.backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: _bloodGroups.map((String group) {
                            return DropdownMenuItem<String>(
                              value: group,
                              child: Text(
                                group,
                                style: AppStyle.normalTextStyle.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedBloodGroup = newValue;
                            });
                          },
                        ),
                        SizedBox(height: SizeConfig.getProportionateHeight(25)),
                        CommonButton(
                          onTap: () {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text.trim();
                            final name = _nameController.text.trim();
                            final phoneNumber =
                                _phoneNumberController.text.trim();
                            final district = _districtcontroller.text.trim();

                            if (_selectedBloodGroup == null ||
                                email.isEmpty ||
                                password.isEmpty ||
                                name.isEmpty ||
                                phoneNumber.isEmpty ||
                                district.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please fill all fields')),
                              );
                              return;
                            }

                            ref
                                .read(authControllerProvider.notifier)
                                .createUserWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                    name: name,
                                    phoneNumber: phoneNumber,
                                    bloodGroup: _selectedBloodGroup!,
                                    district: district,
                                    type: widget.type);
                          },
                          title: 'Register Now',
                          isLoading: state.isLoading,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: SizeConfig.getProportionateHeight(20)),
                  TextButton(
                    onPressed: () {
                      context.goNamed(AppRoutes.signIn.name);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.grey.shade600),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: AppStyle.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig.getProportionateHeight(20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
