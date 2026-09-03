import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/standing_entry.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../../shared/widgets/fixture_card.dart';
import '../../matches/matches_providers.dart';
import '../competitions_providers.dart';

class LeagueDetailsScreen extends ConsumerWidget {
  final int leagueId;
  final String leagueName;
  final String leagueLogo;
  final String? leagueCountry;

  const LeagueDetailsScreen({
    super.key,
    required this.leagueId,
    required this.leagueName,
    required this.leagueLogo,
    this.leagueCountry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Row(
            children: [
              if (leagueLogo.isNotEmpty)
                Image.network(leagueLogo, width: 24, height: 24,
                    errorBuilder: (_, _, _) => const Icon(Icons.emoji_events_outlined, size: 20)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(leagueName, overflow: TextOverflow.ellipsis)),
            ],
          ),
          bottom: const TabBar(
            tabs: [Tab(text: "Standings"), Tab(text: "Fixtures"), Tab(text: "Top Players")],
          ),
        ),
        body: TabBarView(
          children: [
            _StandingsTab(leagueId: leagueId),
            _FixturesTab(leagueId: leagueId),
            _TopPlayersTab(leagueId: leagueId),
          ],
        ),
      ),
    );
  }
}

class _StandingsTab extends ConsumerWidget {
  final int leagueId;
  const _StandingsTab({required this.leagueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(leagueStandingsProvider(leagueId));
    return standingsAsync.when(
      loading: () => const HomeFeedSkeleton(),
      error: (err, _) =>
          AppStateError(message: err.toString(), onRetry: () => ref.invalidate(leagueStandingsProvider(leagueId))),
      data: (rows) {
        if (rows.isEmpty) {
          return const AppStateEmpty(message: "Standings aren't available for this league yet.");
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemCount: rows.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) return const _StandingsHeaderRow();
            return _StandingsRow(entry: rows[i - 1]);
          },
        );
      },
    );
  }
}

class _StandingsHeaderRow extends StatelessWidget {
  const _StandingsHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Row(
        children: [
          const SizedBox(width: 28, child: Text("#", style: AppTypography.caption)),
          const Expanded(child: Text("Team", style: AppTypography.caption)),
          _headerCell("P"),
          _headerCell("GD"),
          _headerCell("Pts"),
        ],
      ),
    );
  }

  Widget _headerCell(String label) =>
      SizedBox(width: 32, child: Text(label, style: AppTypography.caption, textAlign: TextAlign.center));
}

class _StandingsRow extends StatelessWidget {
  final StandingEntry entry;
  const _StandingsRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text("${entry.rank}", style: AppTypography.body)),
          Image.network(entry.teamLogo, width: 20, height: 20,
              errorBuilder: (_, _, _) => const Icon(Icons.shield_outlined, size: 18)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(entry.teamName, style: AppTypography.body, overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 32, child: Text("${entry.played}", style: AppTypography.caption, textAlign: TextAlign.center)),
          SizedBox(
            width: 32,
            child: Text(
              entry.goalsDiff > 0 ? "+${entry.goalsDiff}" : "${entry.goalsDiff}",
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 32,
            child: Text("${entry.points}",
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

/// Reuses the same round-navigation providers as the Fixtures page so
/// League Details' "recent results / upcoming fixtures" (section 10)
/// stays consistent with section 7's Fixtures page.
class _FixturesTab extends ConsumerStatefulWidget {
  final int leagueId;
  const _FixturesTab({required this.leagueId});

  @override
  ConsumerState<_FixturesTab> createState() => _FixturesTabState();
}

class _FixturesTabState extends ConsumerState<_FixturesTab> {
  int? _roundIndex;

  @override
  Widget build(BuildContext context) {
    final navAsync = ref.watch(roundNavigationProvider(widget.leagueId));
    return navAsync.when(
      loading: () => const HomeFeedSkeleton(),
      error: (err, _) => AppStateError(
        message: err.toString(),
        onRetry: () => ref.invalidate(roundNavigationProvider(widget.leagueId)),
      ),
      data: (nav) {
        if (nav.rounds.isEmpty) {
          return const AppStateEmpty(message: "No fixtures found for this league yet.");
        }
        final index = (_roundIndex ?? nav.currentIndex).clamp(0, nav.rounds.length - 1);
        final round = nav.rounds[index];
        final fixturesAsync = ref.watch(leagueFixturesProvider((leagueId: widget.leagueId, round: round)));

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
                  onRetry: () =>
                      ref.invalidate(leagueFixturesProvider((leagueId: widget.leagueId, round: round))),
                ),
                data: (fixtures) {
                  if (fixtures.isEmpty) {
                    return const AppStateEmpty(message: "No fixtures for this round.");
                  }
                  return ListView.separated(
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

class _TopPlayersTab extends ConsumerWidget {
  final int leagueId;
  const _TopPlayersTab({required this.leagueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scorersAsync = ref.watch(leagueTopScorersProvider(leagueId));
    final assistsAsync = ref.watch(leagueTopAssistsProvider(leagueId));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text("Top Scorers", style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        scorersAsync.when(
          loading: () => const ShimmerBox(height: 120),
          error: (err, _) => Text(err.toString(), style: AppTypography.bodyMuted),
          data: (players) => players.isEmpty
              ? const Text("No data available yet.", style: AppTypography.bodyMuted)
              : Column(children: players.take(10).map((p) => _PlayerStatRow(name: p.playerName, team: p.teamName, photo: p.playerPhoto, value: p.value, label: "goals")).toList()),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text("Top Assists", style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        assistsAsync.when(
          loading: () => const ShimmerBox(height: 120),
          error: (err, _) => Text(err.toString(), style: AppTypography.bodyMuted),
          data: (players) => players.isEmpty
              ? const Text("No data available yet.", style: AppTypography.bodyMuted)
              : Column(children: players.take(10).map((p) => _PlayerStatRow(name: p.playerName, team: p.teamName, photo: p.playerPhoto, value: p.value, label: "assists")).toList()),
        ),
      ],
    );
  }
}

class _PlayerStatRow extends StatelessWidget {
  final String name;
  final String team;
  final String photo;
  final int value;
  final String label;
  const _PlayerStatRow({
    required this.name,
    required this.team,
    required this.photo,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surfaceElevated,
            backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
            child: photo.isEmpty ? const Icon(Icons.person, size: 16, color: AppColors.textMuted) : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.body),
                Text(team, style: AppTypography.caption),
              ],
            ),
          ),
          Text("$value $label", style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
