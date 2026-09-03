import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

/// Common chrome for User Information / Favorite Teams / Favorite Leagues
/// (spec section 3) so the three steps read as one continuous flow rather
/// than three unrelated screens.
class OnboardingStepScaffold extends StatelessWidget {
  final int step;
  final int totalSteps;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onSkip;
  final VoidCallback onNext;
  final String nextLabel;
  final bool nextEnabled;
  final bool loading;
  final String? error;

  const OnboardingStepScaffold({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onNext,
    this.onSkip,
    this.nextLabel = "Next",
    this.nextEnabled = true,
    this.loading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: List.generate(totalSteps, (i) {
                        final active = i < step;
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: active ? AppColors.brandGreenBright : AppColors.divider,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  if (onSkip != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    TextButton(onPressed: onSkip, child: const Text("Skip")),
                  ],
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.h1),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle, style: AppTypography.bodyMuted),
                    const SizedBox(height: AppSpacing.xl),
                    if (error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(error!, style: AppTypography.body.copyWith(color: AppColors.error)),
                      ),
                    ],
                    child,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppComponentStyles.primaryButton,
                  onPressed: (nextEnabled && !loading) ? onNext : null,
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandNavyDark),
                        )
                      : Text(nextLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
