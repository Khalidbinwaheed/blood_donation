import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInScreen extends ConsumerStatefulWidget{
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();

}

class _SignInScreenState extends ConsumerState<SignInScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Sign In Screen'),
      ),
    );
  }
}