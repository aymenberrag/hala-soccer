import 'package:flutter/material.dart';

import '../../../core/constants/league_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

class CompetitionsScreen extends StatelessWidget {
  const CompetitionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Competitions")),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: featuredLeagues.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final league = featuredLeagues[i];
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppComponentStyles.card,
            child: Row(
              children: [
                Image.network(
                  league["logo"] as String,
                  width: 36,
                  height: 36,
                  errorBuilder: (_, __, ___) => const Icon(Icons.shield_outlined, color: AppColors.textMuted),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(league["name"] as String, style: AppTypography.h3),
                      Text(league["country"] as String, style: AppTypography.caption),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          );
        },
      ),
    );
  }
}
