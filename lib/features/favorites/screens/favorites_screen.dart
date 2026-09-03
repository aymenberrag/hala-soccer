import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../../shared/widgets/fixture_card.dart';
import '../favorites_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  void _refresh(WidgetRef ref) {
    ref.invalidate(favoritesProvider);
    ref.invalidate(favoriteLeaguesProvider);
    ref.invalidate(favoritesActivityProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(favoritesProvider);
    final leaguesAsync = ref.watch(favoriteLeaguesProvider);
    final activityAsync = ref.watch(favoritesActivityProvider);

    final isEmpty = teamsAsync.valueOrNull?.isEmpty != false && leaguesAsync.valueOrNull?.isEmpty != false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Favorites")),
      body: RefreshIndicator(
        color: AppColors.brandGreenBright,
        backgroundColor: AppColors.surfaceElevated,
        onRefresh: () async => _refresh(ref),
        child: (teamsAsync.isLoading && leaguesAsync.isLoading)
            ? const HomeFeedSkeleton()
            : isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: AppSpacing.xxl),
                      AppStateEmpty(
                        icon: Icons.star_border_rounded,
                        message:
                            "You haven't favorited any teams or leagues yet.\nAdd some during onboarding or from Profile.",
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      if (teamsAsync.valueOrNull?.isNotEmpty == true) ...[
                        Text("My Teams", style: AppTypography.h3),
                        const SizedBox(height: AppSpacing.sm),
                        ...teamsAsync.value!.map((fav) => _FavoriteChipRow(
                              logo: fav.teamLogo,
                              name: fav.teamName ?? "Team #${fav.teamId}",
                              onRemove: () async {
                                await ref.read(favoritesServiceProvider).removeTeam(fav.id);
                                ref.invalidate(favoritesProvider);
                              },
                            )),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (leaguesAsync.valueOrNull?.isNotEmpty == true) ...[
                        Text("My Leagues", style: AppTypography.h3),
                        const SizedBox(height: AppSpacing.sm),
                        ...leaguesAsync.value!.map((fav) => _FavoriteChipRow(
                              logo: fav.leagueLogo,
                              name: fav.leagueName ?? "League #${fav.leagueId}",
                              onRemove: () async {
                                await ref.read(favoritesServiceProvider).removeLeague(fav.id);
                                ref.invalidate(favoriteLeaguesProvider);
                              },
                            )),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      activityAsync.when(
                        loading: () => const ShimmerBox(height: 88),
                        error: (_, _) => const SizedBox.shrink(),
                        data: (activity) {
                          if (activity.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (activity.upcoming.isNotEmpty) ...[
                                Text("Upcoming", style: AppTypography.h3),
                                const SizedBox(height: AppSpacing.sm),
                                ...activity.upcoming.map((f) => Padding(
                                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                      child: FixtureCard(
                                        fixture: f,
                                        onTap: () => context.push("${AppRoutes.fixtureDetails}/${f.id}", extra: f),
                                      ),
                                    )),
                                const SizedBox(height: AppSpacing.lg),
                              ],
                              if (activity.recentResults.isNotEmpty) ...[
                                Text("Recent Results", style: AppTypography.h3),
                                const SizedBox(height: AppSpacing.sm),
                                ...activity.recentResults.map((f) => Padding(
                                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                      child: FixtureCard(
                                        fixture: f,
                                        onTap: () => context.push("${AppRoutes.fixtureDetails}/${f.id}", extra: f),
                                      ),
                                    )),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _FavoriteChipRow extends StatelessWidget {
  final String? logo;
  final String name;
  final VoidCallback onRemove;
  const _FavoriteChipRow({required this.logo, required this.name, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: AppComponentStyles.card,
        child: Row(
          children: [
            (logo != null && logo!.isNotEmpty)
                ? Image.network(logo!, width: 28, height: 28,
                    errorBuilder: (_, _, _) => const Icon(Icons.shield_outlined, color: AppColors.textMuted))
                : const Icon(Icons.shield_outlined, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(name, style: AppTypography.body)),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
