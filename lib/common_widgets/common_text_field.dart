import 'package:blood_donation/util/appstyles.dart';
import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    required this.hintText,
    required this.textInputType,
    this.obscureText,
    this.controller,
    this.prefixIcon,
    this.fillColor,
    this.filled = false,
  });
  final String hintText;
  final TextInputType textInputType;
  final bool? obscureText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Color? fillColor;
  final bool? filled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: textInputType,
      controller: controller,
      obscureText: obscureText ?? false,
      style: AppStyle.normalTextStyle.copyWith(color: AppStyle.textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppStyle.normalTextStyle.copyWith(color: Colors.grey),
        prefixIcon: prefixIcon,
        filled: filled,
        fillColor: fillColor ?? Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppStyle.primaryColor, width: 2.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
    );
  }
}
