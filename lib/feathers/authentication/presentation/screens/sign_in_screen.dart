import 'package:blood_donation/common_widgets/common_text_field.dart';
import 'package:blood_donation/util/appstyles.dart';
import 'package:blood_donation/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return Column(
      children: [
        Image.asset(
          'assets/logo.png',
          height: SizeConfig.getProportionateHeight(100),
          width: SizeConfig.getProportionateWidth(100),
          fit: BoxFit.cover,
        ),
        Text(
          'Sign in to your account',
          style: AppStyle.titleTextStyle.copyWith(color: Colors.black),
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
        
      ],
    );
  }
}
