import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

class AppComponentStyles {
  AppComponentStyles._();

  static BoxDecoration card = BoxDecoration(
    color: AppColors.surfaceCard,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(color: AppColors.divider),
  );

  static BoxDecoration elevatedCard = BoxDecoration(
    color: AppColors.surfaceElevated,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    boxShadow: AppShadows.card,
  );

  static BoxDecoration gradientCard = BoxDecoration(
    gradient: AppColors.brandGradient,
    borderRadius: BorderRadius.circular(AppRadius.lg),
  );

  static InputDecoration textField({
    required String label,
    String? hint,
    Widget? suffixIcon,
    String? errorText,
  }) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: color),
        );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceElevated,
      labelStyle: AppTypography.bodyMuted,
      hintStyle: AppTypography.bodyMuted,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: border(AppColors.divider),
      enabledBorder: border(AppColors.divider),
      focusedBorder: border(AppColors.brandGreenBright),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error),
    );
  }

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.brandGreenBright,
    foregroundColor: AppColors.brandNavyDark,
    disabledBackgroundColor: AppColors.brandGreenBright.withValues(alpha: 0.4),
    minimumSize: const Size.fromHeight(52),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    textStyle: AppTypography.button.copyWith(color: AppColors.brandNavyDark),
    elevation: 0,
  );

  static ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textPrimary,
    minimumSize: const Size.fromHeight(52),
    side: const BorderSide(color: AppColors.divider),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    textStyle: AppTypography.button,
  );

  static ButtonStyle textButton = TextButton.styleFrom(
    foregroundColor: AppColors.brandGreenBright,
    textStyle: AppTypography.button.copyWith(fontSize: 14),
  );
}
