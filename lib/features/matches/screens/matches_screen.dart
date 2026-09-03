import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/fixture.dart';
import '../../../data/models/league_summary.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../../shared/widgets/fixture_card.dart';
import '../matches_providers.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  int? _selectedLeagueId;

  @override
  Widget build(BuildContext context) {
    final leaguesAsync = ref.watch(relevantLeaguesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Fixtures")),
      body: leaguesAsync.when(
        loading: () => const HomeFeedSkeleton(),
        error: (err, _) => AppStateError(message: err.toString(), onRetry: () => ref.invalidate(relevantLeaguesProvider)),
        data: (leagues) {
          if (leagues.isEmpty) {
            return const AppStateEmpty(message: "No leagues to show yet.");
          }
          final selected = leagues.firstWhere(
            (l) => l.id == _selectedLeagueId,
            orElse: () => leagues.first,
          );

          return Column(
            children: [
              _LeagueSelector(
                leagues: leagues,
                selectedId: selected.id,
                onSelect: (id) => setState(() => _selectedLeagueId = id),
              ),
              const Divider(color: AppColors.divider, height: 1),
              Expanded(child: _RoundFixtures(league: selected)),
            ],
          );
        },
      ),
    );
  }
}

class _LeagueSelector extends StatelessWidget {
  final List<LeagueSummary> leagues;
  final int selectedId;
  final ValueChanged<int> onSelect;
  const _LeagueSelector({required this.leagues, required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        itemCount: leagues.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final league = leagues[i];
          final selected = league.id == selectedId;
          return InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: () => onSelect(league.id),
            child: Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: selected ? AppColors.brandGreenBright.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: selected ? AppColors.brandGreenBright : AppColors.divider),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  league.logo.isNotEmpty
                      ? Image.network(league.logo, width: 28, height: 28,
                          errorBuilder: (_, _, _) => const Icon(Icons.emoji_events_outlined, size: 24))
                      : const Icon(Icons.emoji_events_outlined, size: 24, color: AppColors.textMuted),
                  const SizedBox(height: 4),
                  Text(
                    league.name,
                    style: AppTypography.caption.copyWith(
                      color: selected ? AppColors.brandGreenBright : AppColors.textMuted,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoundFixtures extends ConsumerStatefulWidget {
  final LeagueSummary league;
  const _RoundFixtures({required this.league});

  @override
  ConsumerState<_RoundFixtures> createState() => _RoundFixturesState();
}

class _RoundFixturesState extends ConsumerState<_RoundFixtures> {
  int? _roundIndex;

  @override
  void didUpdateWidget(covariant _RoundFixtures oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.league.id != widget.league.id) {
      setState(() => _roundIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final navAsync = ref.watch(roundNavigationProvider(widget.league.id));

    return navAsync.when(
      loading: () => const HomeFeedSkeleton(),
      error: (err, _) =>
          AppStateError(message: err.toString(), onRetry: () => ref.invalidate(roundNavigationProvider(widget.league.id))),
      data: (nav) {
        if (nav.rounds.isEmpty) {
          return const AppStateEmpty(message: "No rounds found for this league yet.");
        }
        final index = (_roundIndex ?? nav.currentIndex).clamp(0, nav.rounds.length - 1);
        final round = nav.rounds[index];

        final fixturesAsync = ref.watch(leagueFixturesProvider((leagueId: widget.league.id, round: round)));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    color: index > 0 ? AppColors.textPrimary : AppColors.textMuted,
                    onPressed: index > 0 ? () => setState(() => _roundIndex = index - 1) : null,
                  ),
                  Expanded(
                    child: Text(round, style: AppTypography.h3, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    color: index < nav.rounds.length - 1 ? AppColors.textPrimary : AppColors.textMuted,
                    onPressed:
                        index < nav.rounds.length - 1 ? () => setState(() => _roundIndex = index + 1) : null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: fixturesAsync.when(
                loading: () => const HomeFeedSkeleton(),
                error: (err, _) => AppStateError(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(leagueFixturesProvider((leagueId: widget.league.id, round: round))),
                ),
                data: (fixtures) {
                  if (fixtures.isEmpty) {
                    return const AppStateEmpty(message: "No fixtures for this round.");
                  }
                  return RefreshIndicator(
                    color: AppColors.brandGreenBright,
                    backgroundColor: AppColors.surfaceElevated,
                    onRefresh: () async =>
                        ref.invalidate(leagueFixturesProvider((leagueId: widget.league.id, round: round))),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: fixtures.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final f = fixtures[i];
                        return FixtureCard(
                          fixture: f,
                          onTap: () => context.push("${AppRoutes.fixtureDetails}/${f.id}", extra: f),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
