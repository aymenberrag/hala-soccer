import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/league_summary.dart';
import '../../home/home_providers.dart';
import '../preferences_draft_controller.dart';
import 'onboarding_step_scaffold.dart';

class FavoriteLeaguesScreen extends ConsumerStatefulWidget {
  const FavoriteLeaguesScreen({super.key});

  @override
  ConsumerState<FavoriteLeaguesScreen> createState() => _FavoriteLeaguesScreenState();
}

class _FavoriteLeaguesScreenState extends ConsumerState<FavoriteLeaguesScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<LeagueSummary> _results = [];
  bool _searching = false;
  String? _searchError;
  bool _submitting = false;
  String? _submitError;

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
      setState(() {
        _results = [];
        _searching = false;
        _searchError = null;
      });
      return;
    }
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final results = await ref.read(footballRepositoryProvider).searchLeagues(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _searchError = "Couldn't search leagues. Check your connection.";
      });
    }
  }

  Future<void> _finish() async {
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    final error = await ref.read(preferencesDraftProvider.notifier).submit();
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _submitting = false;
        _submitError = error;
      });
      return;
    }
    // Router redirect (driven by AuthController.user.preferencesComplete)
    // takes it from here — no manual navigation needed.
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(preferencesDraftProvider);
    final draftNotifier = ref.read(preferencesDraftProvider.notifier);

    return OnboardingStepScaffold(
      step: 3,
      totalSteps: 3,
      title: "Favorite Leagues",
      subtitle: "Pick the competitions you want front and center on Home.",
      onSkip: _finish,
      onNext: _finish,
      nextLabel: draft.leagues.isEmpty ? "Finish" : "Finish (${draft.leagues.length} selected)",
      loading: _submitting,
      error: _submitError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onQueryChanged,
            style: AppTypography.body,
            decoration: AppComponentStyles.textField(
              label: "Search leagues",
              hint: "e.g. Premier League",
              suffixIcon: const Icon(Icons.search, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (draft.leagues.isNotEmpty) ...[
            Text("Selected", style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: draft.leagues
                  .map((l) => _SelectedChip(label: l.name, onRemove: () => draftNotifier.toggleLeague(l)))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (_searching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(child: CircularProgressIndicator(color: AppColors.brandGreenBright)),
            )
          else if (_searchError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(_searchError!, style: AppTypography.bodyMuted),
            )
          else if (_searchController.text.trim().length >= 3 && _results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text("No leagues found for \"${_searchController.text.trim()}\".",
                  style: AppTypography.bodyMuted),
            )
          else
            ..._results.map((league) {
              final selected = draftNotifier.hasLeague(league.id);
              return _LeagueTile(
                league: league,
                selected: selected,
                onTap: () => draftNotifier.toggleLeague(league),
              );
            }),
        ],
      ),
    );
  }
}

class _LeagueTile extends StatelessWidget {
  final LeagueSummary league;
  final bool selected;
  final VoidCallback onTap;
  const _LeagueTile({required this.league, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: selected ? AppColors.brandGreenBright.withValues(alpha: 0.12) : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Image.network(
                  league.logo,
                  width: 32,
                  height: 32,
                  errorBuilder: (_, _, _) => const Icon(Icons.emoji_events_outlined, color: AppColors.textMuted),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(league.name, style: AppTypography.body),
                      if (league.country != null) Text(league.country!, style: AppTypography.caption),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.add_circle_outline,
                  color: selected ? AppColors.brandGreenBright : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _SelectedChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      onDeleted: onRemove,
      backgroundColor: AppColors.surfaceElevated,
      labelStyle: AppTypography.body,
      deleteIconColor: AppColors.textMuted,
      side: const BorderSide(color: AppColors.divider),
    );
  }
}
