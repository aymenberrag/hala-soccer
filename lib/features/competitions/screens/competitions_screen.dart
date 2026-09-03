import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/league_summary.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../competitions_providers.dart';

class CompetitionsScreen extends ConsumerWidget {
  const CompetitionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaguesAsync = ref.watch(leaguesPageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Leagues")),
      body: leaguesAsync.when(
        loading: () => const HomeFeedSkeleton(),
        error: (err, _) => AppStateError(message: err.toString(), onRetry: () => ref.invalidate(leaguesPageProvider)),
        data: (leagues) {
          if (leagues.isEmpty) {
            return const AppStateEmpty(message: "No leagues to show yet.");
          }
          return RefreshIndicator(
            color: AppColors.brandGreenBright,
            backgroundColor: AppColors.surfaceElevated,
            onRefresh: () async => ref.invalidate(leaguesPageProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: leagues.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) => _LeagueRow(league: leagues[i]),
            ),
          );
        },
      ),
    );
  }
}

class _LeagueRow extends StatelessWidget {
  final LeagueSummary league;
  const _LeagueRow({required this.league});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () => context.push(
        "${AppRoutes.leagueDetails}/${league.id}",
        extra: {"id": league.id, "name": league.name, "logo": league.logo, "country": league.country},
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: AppComponentStyles.card,
        child: Row(
          children: [
            league.logo.isNotEmpty
                ? Image.network(league.logo, width: 36, height: 36,
                    errorBuilder: (_, _, _) => const Icon(Icons.shield_outlined, color: AppColors.textMuted))
                : const Icon(Icons.shield_outlined, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(league.name, style: AppTypography.h3),
                  if (league.country != null) Text(league.country!, style: AppTypography.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
