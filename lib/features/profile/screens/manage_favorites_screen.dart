import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../home/home_providers.dart';
import '../../favorites/favorites_providers.dart';

enum ManageFavoritesKind { teams, leagues }

class ManageFavoritesScreen extends ConsumerStatefulWidget {
  final ManageFavoritesKind kind;
  const ManageFavoritesScreen({super.key, required this.kind});

  @override
  ConsumerState<ManageFavoritesScreen> createState() => _ManageFavoritesScreenState();
}

class _ManageFavoritesScreenState extends ConsumerState<ManageFavoritesScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<dynamic> _results = []; // Team or LeagueSummary depending on kind
  bool _searching = false;

  bool get _isTeams => widget.kind == ManageFavoritesKind.teams;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    if (query.trim().length < 3) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    final repo = ref.read(footballRepositoryProvider);
    final results = _isTeams ? await repo.searchTeams(query) : await repo.searchLeagues(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Explicit common type: the two branches watch differently-typed
    // providers (List<FavoriteTeam> vs List<FavoriteLeague>), and this
    // screen only ever reads shared duck-typed fields (name/logo/id) off
    // whichever one is active.
    final AsyncValue<List<dynamic>> currentAsync =
        _isTeams ? ref.watch(favoritesProvider) : ref.watch(favoriteLeaguesProvider);
    final service = ref.read(favoritesServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isTeams ? "Favorite Teams" : "Favorite Leagues")),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
              style: AppTypography.body,
              decoration: AppComponentStyles.textField(
                label: _isTeams ? "Search teams" : "Search leagues",
                suffixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView(
                children: [
                  currentAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (current) {
                      if (current.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Currently favorited", style: AppTypography.h3),
                          const SizedBox(height: AppSpacing.sm),
                          ...current.map((fav) {
                            final name = _isTeams ? fav.teamName : fav.leagueName;
                            final logo = _isTeams ? fav.teamLogo : fav.leagueLogo;
                            return _Tile(
                              name: name ?? "—",
                              logo: logo,
                              trailing: IconButton(
                                icon: const Icon(Icons.check_circle, color: AppColors.brandGreenBright),
                                onPressed: () async {
                                  if (_isTeams) {
                                    await service.removeTeam(fav.id);
                                    ref.invalidate(favoritesProvider);
                                  } else {
                                    await service.removeLeague(fav.id);
                                    ref.invalidate(favoriteLeaguesProvider);
                                  }
                                },
                              ),
                            );
                          }),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      );
                    },
                  ),
                  if (_searching)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Center(child: CircularProgressIndicator(color: AppColors.brandGreenBright)),
                    )
                  else
                    ..._results.map((item) {
                      final name = _isTeams ? item.name : item.name;
                      final logo = _isTeams ? item.logo : item.logo;
                      return _Tile(
                        name: name,
                        logo: logo,
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.textMuted),
                          onPressed: () async {
                            if (_isTeams) {
                              await service.addTeam(teamId: item.id, teamName: item.name, teamLogo: item.logo);
                              ref.invalidate(favoritesProvider);
                            } else {
                              await service.addLeague(
                                leagueId: item.id,
                                leagueName: item.name,
                                leagueLogo: item.logo,
                                leagueCountry: item.country,
                              );
                              ref.invalidate(favoriteLeaguesProvider);
                            }
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String name;
  final String? logo;
  final Widget trailing;
  const _Tile({required this.name, required this.logo, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: AppComponentStyles.card,
        child: Row(
          children: [
            (logo != null && logo!.isNotEmpty)
                ? Image.network(logo!, width: 28, height: 28,
                    errorBuilder: (_, _, _) => const Icon(Icons.shield_outlined, color: AppColors.textMuted))
                : const Icon(Icons.shield_outlined, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(name, style: AppTypography.body)),
            trailing,
          ],
        ),
      ),
    );
  }
}
