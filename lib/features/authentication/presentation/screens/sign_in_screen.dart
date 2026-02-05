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

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          // Background Header with Curve and Gradient
          Container(
            height: SizeConfig.screenHeight * 0.4,
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
                      height: SizeConfig.getProportionateHeight(80),
                      width: SizeConfig.getProportionateWidth(80),
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome Back',
                    style: AppStyle.headingTextStyle.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Sign in to continue saving lives',
                    style: AppStyle.normalTextStyle.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: SizeConfig.screenHeight * 0.35),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          'Login',
                          style: AppStyle.titleTextStyle.copyWith(fontSize: 24),
                        ),
                        SizedBox(height: SizeConfig.getProportionateHeight(25)),
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
                          textInputType: TextInputType.text,
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.grey),
                          filled: true,
                          fillColor: AppStyle.backgroundColor,
                        ),
                        SizedBox(height: SizeConfig.getProportionateHeight(25)),
                        CommonButton(
                            onTap: () {
                              final email = _emailController.text.toString();
                              final password =
                                  _passwordController.text.toString();

                              ref
                                  .read(authControllerProvider.notifier)
                                  .signInWithEmailAndPassword(
                                      email: email, password: password);
                            },
                            title: 'Sign In',
                            isLoading: state.isLoading),
                      ],
                    ),
                  ),
                  SizedBox(height: SizeConfig.getProportionateHeight(25)),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('OR',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: SizeConfig.getProportionateHeight(25)),
                  OutlinedButton(
                    onPressed: () {
                      context.goNamed(
                        AppRoutes.register.name,
                        extra: 'Recipient',
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppStyle.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Register as a Recipient',
                      style: AppStyle.normalTextStyle.copyWith(
                        color: AppStyle.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig.getProportionateHeight(15)),
                  TextButton(
                    onPressed: () {
                      context.goNamed(AppRoutes.register.name, extra: 'Donor');
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Want to donate? ",
                        style: TextStyle(color: Colors.grey.shade600),
                        children: [
                          TextSpan(
                            text: 'Register as Donor',
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
