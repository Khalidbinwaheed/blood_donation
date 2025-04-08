import 'package:blood_donation/common_widgets/common_button.dart';
import 'package:blood_donation/common_widgets/common_text_field.dart';
import 'package:blood_donation/feathers/authentication/presentation/controllers/auth_controller.dart';
import 'package:blood_donation/routes/routes.dart';
import 'package:blood_donation/util/appstyles.dart';
import 'package:blood_donation/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppStyle.mainColor,
        body: Padding(
          padding: EdgeInsets.fromLTRB(
            SizeConfig.getProportionateWidth(10),
            SizeConfig.getProportionateHeight(50),
            SizeConfig.getProportionateWidth(10),
            0,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: SizeConfig.getProportionateHeight(100),
                    width: SizeConfig.getProportionateWidth(100),
                    fit: BoxFit.cover,
                  ),
                  Text(
                    'Sign in to your account',
                    style:
                        AppStyle.titleTextStyle.copyWith(color: Colors.black),
                  ),
                  SizedBox(height: SizeConfig.getProportionateHeight(25)),
                  CommonTextField(
                    hintText: 'Email',
                    textInputType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  SizedBox(height: SizeConfig.getProportionateHeight(10)),
                  CommonTextField(
                    hintText: 'Enter Password',
                    textInputType: TextInputType.text,
                    controller: _passwordController,
                  ),
                  SizedBox(height: SizeConfig.getProportionateHeight(10)),
                  CommonButton(
                      onTap: () {
                        final email = _emailController.text.toString();
                        final password = _passwordController.text.toString();

                        ref
                            .read(authControllerProvider.notifier)
                            .signInWithEmailAndPassword(
                                email: email, password: password);
                      },
                      title: 'Sign In',
                      isLoading: false),
                  SizedBox(height: SizeConfig.getProportionateHeight(15)),
                  Text(
                    'Or',
                    style:
                        AppStyle.titleTextStyle.copyWith(color: Colors.black),
                  ),
                  SizedBox(height: SizeConfig.getProportionateHeight(15)),
                  GestureDetector(
                    onTap: () {
                      context.goNamed(
                        AppRoutes.register.name,
                        extra: 'Recipient',
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: SizeConfig.screenWidth,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Text(
                        'Register as a Recipient',
                        style: AppStyle.normalTextStyle.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig.getProportionateHeight(10)),
                  GestureDetector(
                    onTap: () {
                      context.goNamed(AppRoutes.register.name, extra: 'Donor');
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: SizeConfig.screenWidth,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Text(
                        'Register as a Donor',
                        style: AppStyle.normalTextStyle.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig.getProportionateHeight(10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
