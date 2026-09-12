import 'package:flutter/material.dart';

abstract final class AppThemeColors {
  static const navy = Color(0xFF191C32);
  static const orange = Color(0xFFF7931A);
  static const mint = Color(0xFF5FC88F);
  static const background = Color(0xFFF7F7FA);
  static const border = Color(0xFFE6E7EC);
  static const mutedText = Color(0xFF6B7280);
  static const softMint = Color(0xFFDEF5E9);
  static const softOrange = Color(0xFFFFEBE4);
}

abstract final class AppThemeStyles {
  static const inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    borderSide: BorderSide(color: AppThemeColors.border),
  );

  static const focusedInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    borderSide: BorderSide(color: AppThemeColors.orange, width: 1.5),
  );
}
