import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/fixture.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../../shared/widgets/fixture_card.dart';
import '../../auth/auth_controller.dart';
import '../home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(curatedHomeFeedProvider);
    final user = ref.watch(authControllerProvider).user;

    void refresh() {
      ref.invalidate(homeFeedProvider);
      ref.invalidate(homeCurationProvider);
      ref.invalidate(curatedHomeFeedProvider);
    }

    void openFixture(Fixture f) => context.push("${AppRoutes.fixtureDetails}/${f.id}", extra: f);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brandGreenBright,
          backgroundColor: AppColors.surfaceElevated,
          onRefresh: () async => refresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(name: user?.name)),
              feedAsync.when(
                loading: () => const SliverToBoxAdapter(child: HomeFeedSkeleton()),
                error: (err, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppStateError(message: err.toString(), onRetry: refresh),
                ),
                data: (feed) {
                  if (feed.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppStateEmpty(message: "No relevant matches right now. Check back soon."),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      if (feed.featured != null)
                        _FeaturedFixture(fixture: feed.featured!, onTap: () => openFixture(feed.featured!)),
                      if (feed.live.isNotEmpty)
                        _Section(title: "Live Now", fixtures: feed.live, onTapFixture: openFixture),
                      if (feed.todayResults.isNotEmpty)
                        _Section(title: "Today's Results", fixtures: feed.todayResults, onTapFixture: openFixture),
                      if (feed.yesterdayResults.isNotEmpty)
                        _Section(
                          title: "Yesterday's Results",
                          fixtures: feed.yesterdayResults,
                          onTapFixture: openFixture,
                        ),
                      if (feed.upcoming.isNotEmpty)
                        _Section(title: "Upcoming Matches", fixtures: feed.upcoming, onTapFixture: openFixture),
                      const SizedBox(height: AppSpacing.xxl),
                    ]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String? name;
  const _Header({this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("HALA SOCCER", style: AppTypography.h2),
              if (name != null)
                Text("Welcome back, ${name!.split(' ').first}", style: AppTypography.caption),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(gradient: AppColors.brandGradient, shape: BoxShape.circle),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

/// The "large featured match" (spec section 4) — whatever the AI curator
/// picked as today's single most important game.
class _FeaturedFixture extends StatelessWidget {
  final Fixture fixture;
  final VoidCallback onTap;
  const _FeaturedFixture({required this.fixture, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      fixture.isLive ? "LIVE • FEATURED" : "FEATURED MATCH",
                      style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  Text(fixture.leagueName, style: AppTypography.caption.copyWith(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: _FeaturedTeam(name: fixture.homeTeamName, logo: fixture.homeTeamLogo)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text(
                      fixture.scoreDisplay,
                      style: AppTypography.display.copyWith(color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: _FeaturedTeam(name: fixture.awayTeamName, logo: fixture.awayTeamLogo, alignEnd: true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedTeam extends StatelessWidget {
  final String name;
  final String logo;
  final bool alignEnd;
  const _FeaturedTeam({required this.name, required this.logo, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    final crest = Image.network(
      logo,
      width: 40,
      height: 40,
      errorBuilder: (_, _, _) => const Icon(Icons.shield, size: 32, color: Colors.white70),
    );
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

class _Section extends StatelessWidget {
  final String title;
  final List<Fixture> fixtures;
  final void Function(Fixture) onTapFixture;
  const _Section({required this.title, required this.fixtures, required this.onTapFixture});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(title, style: AppTypography.h3),
          ),
          ...fixtures.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: FixtureCard(fixture: f, onTap: () => onTapFixture(f)),
            ),
          ),
        ],
      ),
    );
  }
}
