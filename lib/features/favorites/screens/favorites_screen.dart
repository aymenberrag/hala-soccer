import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_state_widgets.dart';
import '../favorites_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Favorites")),
      body: favoritesAsync.when(
        loading: () => const HomeFeedSkeleton(),
        error: (err, _) => AppStateError(
          message: err.toString(),
          onRetry: () => ref.invalidate(favoritesProvider),
        ),
        data: (favorites) {
          if (favorites.isEmpty) {
            return const AppStateEmpty(
              icon: Icons.star_border_rounded,
              message: "You haven't favorited any teams yet.\nFavorite a team from a match card to see it here.",
            );
          }
          return RefreshIndicator(
            color: AppColors.brandGreenBright,
            backgroundColor: AppColors.surfaceElevated,
            onRefresh: () async => ref.invalidate(favoritesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: favorites.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final fav = favorites[i];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: AppComponentStyles.card,
                  child: Row(
                    children: [
                      if (fav.teamLogo != null)
                        Image.network(fav.teamLogo!, width: 32, height: 32,
                            errorBuilder: (_, _, _) => const Icon(Icons.shield_outlined))
                      else
                        const Icon(Icons.shield_outlined, color: AppColors.textMuted),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(fav.teamName ?? "Team #${fav.teamId}", style: AppTypography.body),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                        onPressed: () async {
                          await ref.read(favoritesServiceProvider).remove(fav.id);
                          ref.invalidate(favoritesProvider);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
