import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_component_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/fixture.dart';

class FixtureCard extends StatelessWidget {
  final Fixture fixture;
  final VoidCallback? onTap;

  const FixtureCard({super.key, required this.fixture, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: AppComponentStyles.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(fixture.leagueLogo, width: 16, height: 16, errorBuilder: (_, _, _) => const SizedBox(width: 16)),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    fixture.leagueName,
                    style: AppTypography.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusPill(fixture: fixture),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(child: _TeamRow(name: fixture.homeTeamName, logo: fixture.homeTeamLogo)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(fixture.scoreDisplay, style: AppTypography.h3),
                ),
                Expanded(
                  child: _TeamRow(name: fixture.awayTeamName, logo: fixture.awayTeamLogo, alignEnd: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  final String name;
  final String logo;
  final bool alignEnd;
  const _TeamRow({required this.name, required this.logo, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    final image = Image.network(logo, width: 24, height: 24, errorBuilder: (_, _, _) => const Icon(Icons.shield, size: 20));
    final text = Expanded(
      child: Text(
        name,
        style: AppTypography.body,
        overflow: TextOverflow.ellipsis,
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
      ),
    );
    return Row(
      children: alignEnd
          ? [text, const SizedBox(width: AppSpacing.xs), image]
          : [image, const SizedBox(width: AppSpacing.xs), text],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Fixture fixture;
  const _StatusPill({required this.fixture});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String label;

    switch (fixture.status) {
      case FixtureStatus.live:
        color = AppColors.live;
        label = fixture.elapsedMinutes != null ? "${fixture.elapsedMinutes}'" : "LIVE";
        break;
      case FixtureStatus.finished:
        color = AppColors.textMuted;
        label = "FT";
        break;
      case FixtureStatus.scheduled:
        color = AppColors.brandGreenBright;
        label = "${fixture.kickoff.hour.toString().padLeft(2, '0')}:${fixture.kickoff.minute.toString().padLeft(2, '0')}";
        break;
      case FixtureStatus.other:
        color = AppColors.textMuted;
        label = fixture.statusShort;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}
