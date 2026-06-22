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
    final theme = Theme.of(context);
    return TextFormField(
      keyboardType: textInputType,
      controller: controller,
      obscureText: obscureText ?? false,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
        ),
        prefixIcon: prefixIcon,
        filled: filled,
        fillColor: fillColor ?? theme.colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
    );
  }
}
