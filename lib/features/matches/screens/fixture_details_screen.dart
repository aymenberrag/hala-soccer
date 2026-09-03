import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/fixture.dart';
import '../../../data/models/fixture_details.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../../shared/widgets/fixture_card.dart';
import '../matches_providers.dart';

/// Everything available from API-Football for one match (spec section 8).
/// Every section is conditional — only info that actually came back from
/// the API is shown, nothing invented or padded out.
class FixtureDetailsScreen extends ConsumerWidget {
  final int fixtureId;
  final Fixture? initialFixture;
  const FixtureDetailsScreen({super.key, required this.fixtureId, this.initialFixture});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync =
        ref.watch(fixtureDetailsProvider((fixtureId: fixtureId, seed: initialFixture)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Match Details")),
      body: detailsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              ShimmerBox(height: 140),
              SizedBox(height: AppSpacing.md),
              ShimmerBox(height: 200),
            ],
          ),
        ),
        error: (err, _) => AppStateError(
          message: err.toString(),
          onRetry: () => ref.invalidate(fixtureDetailsProvider((fixtureId: fixtureId, seed: initialFixture))),
        ),
        data: (details) => _FixtureDetailsBody(details: details),
      ),
    );
  }
}

class _FixtureDetailsBody extends StatelessWidget {
  final FixtureDetails details;
  const _FixtureDetailsBody({required this.details});

  @override
  Widget build(BuildContext context) {
    final f = details.fixture;
    final hasEvents = details.events.isNotEmpty;
    final hasStats = details.statistics.isNotEmpty;
    final hasLineups = details.lineups.isNotEmpty;
    final hasH2H = details.headToHead.isNotEmpty;

    final tabs = <String>[
      if (hasEvents) "Events",
      if (hasStats) "Stats",
      if (hasLineups) "Lineups",
      if (hasH2H) "H2H",
    ];

    return Column(
      children: [
        _ScoreHeader(fixture: f),
        Expanded(
          child: tabs.isEmpty
              ? const AppStateEmpty(
                  icon: Icons.info_outline,
                  message: "More details will appear closer to kickoff.",
                )
              : DefaultTabController(
                  length: tabs.length,
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: true,
                        labelColor: AppColors.brandGreenBright,
                        unselectedLabelColor: AppColors.textMuted,
                        indicatorColor: AppColors.brandGreenBright,
                        tabs: tabs.map((t) => Tab(text: t)).toList(),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            if (hasEvents) _EventsTab(events: details.events),
                            if (hasStats) _StatsTab(statistics: details.statistics),
                            if (hasLineups) _LineupsTab(lineups: details.lineups),
                            if (hasH2H) _H2HTab(fixtures: details.headToHead),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  final Fixture fixture;
  const _ScoreHeader({required this.fixture});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(gradient: AppColors.brandGradientVertical),
      child: Column(
        children: [
          Text(fixture.leagueName, style: AppTypography.caption.copyWith(color: Colors.white70)),
          if (fixture.round != null)
            Text(fixture.round!, style: AppTypography.caption.copyWith(color: Colors.white54)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: _HeaderTeam(name: fixture.homeTeamName, logo: fixture.homeTeamLogo)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    Text(fixture.scoreDisplay, style: AppTypography.display.copyWith(color: Colors.white)),
                    const SizedBox(height: AppSpacing.xs),
                    _StatusLabel(fixture: fixture),
                  ],
                ),
              ),
              Expanded(child: _HeaderTeam(name: fixture.awayTeamName, logo: fixture.awayTeamLogo, alignEnd: true)),
            ],
          ),
          if (fixture.venue != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stadium_outlined, size: 14, color: Colors.white70),
                const SizedBox(width: AppSpacing.xs),
                Text(fixture.venue!, style: AppTypography.caption.copyWith(color: Colors.white70)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final Fixture fixture;
  const _StatusLabel({required this.fixture});

  @override
  Widget build(BuildContext context) {
    String label;
    switch (fixture.status) {
      case FixtureStatus.live:
        label = fixture.elapsedMinutes != null ? "LIVE • ${fixture.elapsedMinutes}'" : "LIVE";
        break;
      case FixtureStatus.finished:
        label = "Full Time";
        break;
      case FixtureStatus.scheduled:
        label =
            "${fixture.kickoff.day}/${fixture.kickoff.month} • ${fixture.kickoff.hour.toString().padLeft(2, '0')}:${fixture.kickoff.minute.toString().padLeft(2, '0')}";
        break;
      case FixtureStatus.other:
        label = fixture.statusShort;
    }
    return Text(
      label,
      style: AppTypography.caption.copyWith(
        color: fixture.isLive ? AppColors.live : Colors.white70,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _HeaderTeam extends StatelessWidget {
  final String name;
  final String logo;
  final bool alignEnd;
  const _HeaderTeam({required this.name, required this.logo, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    final crest = Image.network(logo, width: 44, height: 44,
        errorBuilder: (_, _, _) => const Icon(Icons.shield, size: 36, color: Colors.white70));
    final label = Text(
      name,
      style: AppTypography.body.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      textAlign: alignEnd ? TextAlign.right : TextAlign.left,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [crest, const SizedBox(height: AppSpacing.xs), label],
    );
  }
}

class _EventsTab extends StatelessWidget {
  final List<FixtureEvent> events;
  const _EventsTab({required this.events});

  IconData _iconFor(FixtureEvent e) {
    if (e.isGoal) return Icons.sports_soccer;
    if (e.isSub) return Icons.swap_horiz;
    if (e.isRed) return Icons.square;
    if (e.isYellow) return Icons.square;
    return Icons.circle;
  }

  Color _colorFor(FixtureEvent e) {
    if (e.isGoal) return AppColors.brandGreenBright;
    if (e.isRed) return AppColors.error;
    if (e.isYellow) return AppColors.warning;
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final e = events[i];
        final minute = e.minute != null ? "${e.minute}${e.extraMinute != null ? '+${e.extraMinute}' : ''}'" : "";
        return Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(minute, style: AppTypography.caption, textAlign: TextAlign.center),
            ),
            Icon(_iconFor(e), size: 16, color: _colorFor(e)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.playerName, style: AppTypography.body),
                  Text(
                    "${e.detail}${e.assistName != null ? ' • assist: ${e.assistName}' : ''} • ${e.teamName}",
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatsTab extends StatelessWidget {
  final List<TeamStatistics> statistics;
  const _StatsTab({required this.statistics});

  @override
  Widget build(BuildContext context) {
    if (statistics.length < 2) {
      return const AppStateEmpty(message: "Statistics aren't available for this match yet.");
    }
    final home = statistics[0];
    final away = statistics[1];
    final types = <String>{...home.stats.map((s) => s.type), ...away.stats.map((s) => s.type)}.toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(home.teamName, style: AppTypography.h3, overflow: TextOverflow.ellipsis)),
            Expanded(
              child: Text(away.teamName,
                  style: AppTypography.h3, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...types.map((type) => _StatRow(
              label: type,
              homeValue: home.statValue(type) ?? "-",
              awayValue: away.statValue(type) ?? "-",
            )),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String homeValue;
  final String awayValue;
  const _StatRow({required this.label, required this.homeValue, required this.awayValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(homeValue, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
              Text(label, style: AppTypography.caption),
              Text(awayValue, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Divider(color: AppColors.divider, height: 1),
        ],
      ),
    );
  }
}

class _LineupsTab extends StatelessWidget {
  final List<TeamLineup> lineups;
  const _LineupsTab({required this.lineups});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: lineups.map((team) => _TeamLineupCard(team: team)).toList(),
    );
  }
}

class _TeamLineupCard extends StatelessWidget {
  final TeamLineup team;
  const _TeamLineupCard({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppComponentStyles.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.network(team.teamLogo, width: 24, height: 24,
                  errorBuilder: (_, _, _) => const Icon(Icons.shield_outlined, size: 20)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(team.teamName, style: AppTypography.h3)),
              if (team.formation != null)
                Text(team.formation!, style: AppTypography.caption.copyWith(color: AppColors.brandGreenBright)),
            ],
          ),
          if (team.coachName != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text("Coach: ${team.coachName}", style: AppTypography.caption),
          ],
          const SizedBox(height: AppSpacing.md),
          Text("Starting XI", style: AppTypography.bodyMuted.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          ...team.startXI.map((p) => _PlayerRow(player: p)),
          if (team.substitutes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text("Substitutes", style: AppTypography.bodyMuted.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.xs),
            ...team.substitutes.map((p) => _PlayerRow(player: p)),
          ],
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final LineupPlayer player;
  const _PlayerRow({required this.player});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(player.number?.toString() ?? "", style: AppTypography.caption),
          ),
          Expanded(child: Text(player.name, style: AppTypography.body)),
          if (player.position != null) Text(player.position!, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _H2HTab extends StatelessWidget {
  final List<Fixture> fixtures;
  const _H2HTab({required this.fixtures});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: fixtures.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) => FixtureCard(fixture: fixtures[i]),
    );
  }
}
