import 'package:flutter/widgets.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    required this.hintText,
    required this.textInputType,
    this.obscureText,
    this.controller,
  });
  final String hintText;
  final TextInputType textInputType;
  final bool? obscureText;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
