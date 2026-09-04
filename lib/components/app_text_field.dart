import 'package:flutter/material.dart';
import 'package:xplore_app/config/theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final double height;
  final bool autofocus;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines,
    this.height = 55,
    this.autofocus = false,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        maxLines: maxLines ?? 1,
        autofocus: autofocus,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction ?? TextInputAction.next,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              size: 18,
              prefixIcon,
              color: AppColors.primary,
            ),
          ),
          filled: true,
          fillColor: AppColors.cardColor,
          hintText: hintText,
          hintStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(40)),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(40)),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(40)),
            borderSide: BorderSide(color: AppColors.border),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
