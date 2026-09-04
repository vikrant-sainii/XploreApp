import 'package:flutter/material.dart';
import 'package:xplore_app/config/theme.dart';

class AppDropdownField<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final IconData prefixIcon;
  final List<DropdownMenuItem<T>>? items;
  final ValueChanged<T?>? onChanged;
  final double height;
  final double menuMaxHeight;
  final Color? dropdownColor;
  final EdgeInsetsGeometry? padding;

  const AppDropdownField({
    super.key,
    required this.value,
    required this.hintText,
    required this.prefixIcon,
    required this.items,
    required this.onChanged,
    this.height = 55,
    this.menuMaxHeight = 280,
    this.dropdownColor = const Color(0xFF1E202B),
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DropdownButtonFormField<T>(
        value: value,
        dropdownColor: dropdownColor,
        borderRadius: BorderRadius.circular(16),
        menuMaxHeight: menuMaxHeight,
        elevation: 12,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary, size: 24),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
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
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
