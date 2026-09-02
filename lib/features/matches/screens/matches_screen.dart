import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../../../shared/widgets/fixture_card.dart';
import '../../home/home_providers.dart';

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(homeFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Matches")),
      body: feedAsync.when(
        loading: () => const HomeFeedSkeleton(),
        error: (err, _) => AppStateError(message: err.toString(), onRetry: () => ref.invalidate(homeFeedProvider)),
        data: (feed) {
          final all = [...feed.live, ...feed.upcoming, ...feed.recentResults];
          if (all.isEmpty) {
            return const AppStateEmpty(message: "No matches scheduled today.");
          }
          return RefreshIndicator(
            color: AppColors.brandGreenBright,
            backgroundColor: AppColors.surfaceElevated,
            onRefresh: () async => ref.invalidate(homeFeedProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: all.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) => FixtureCard(fixture: all[i]),
            ),
          );
        },
      ),
    );
  }
}
