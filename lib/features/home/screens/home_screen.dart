import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
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
    final feedAsync = ref.watch(homeFeedProvider);
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brandGreenBright,
          backgroundColor: AppColors.surfaceElevated,
          onRefresh: () async => ref.invalidate(homeFeedProvider),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(name: user?.name)),
              feedAsync.when(
                loading: () => const SliverToBoxAdapter(child: HomeFeedSkeleton()),
                error: (err, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppStateError(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(homeFeedProvider),
                  ),
                ),
                data: (feed) {
                  if (feed.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppStateEmpty(message: "No matches today. Check back soon."),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      if (feed.live.isNotEmpty) _Section(title: "Live Now", fixtures: feed.live),
                      if (feed.upcoming.isNotEmpty) _Section(title: "Upcoming", fixtures: feed.upcoming),
                      if (feed.recentResults.isNotEmpty) _Section(title: "Recent Results", fixtures: feed.recentResults),
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

class _Section extends StatelessWidget {
  final String title;
  final List<Fixture> fixtures;
  const _Section({required this.title, required this.fixtures});

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
              child: FixtureCard(fixture: f),
            ),
          ),
        ],
      ),
    );
  }
}
