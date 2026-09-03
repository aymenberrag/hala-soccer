import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/team.dart';
import '../../home/home_providers.dart';
import '../preferences_draft_controller.dart';
import 'onboarding_step_scaffold.dart';

class FavoriteTeamsScreen extends ConsumerStatefulWidget {
  const FavoriteTeamsScreen({super.key});

  @override
  ConsumerState<FavoriteTeamsScreen> createState() => _FavoriteTeamsScreenState();
}

class _FavoriteTeamsScreenState extends ConsumerState<FavoriteTeamsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<Team> _results = [];
  bool _searching = false;
  String? _searchError;

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
      final results = await ref.read(footballRepositoryProvider).searchTeams(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _searchError = "Couldn't search teams. Check your connection.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(preferencesDraftProvider);
    final draftNotifier = ref.read(preferencesDraftProvider.notifier);

    return OnboardingStepScaffold(
      step: 2,
      totalSteps: 3,
      title: "Favorite Teams",
      subtitle: "Search and select the clubs you follow. You can pick as many as you like.",
      onSkip: () => context.go(AppRoutes.preferencesLeagues),
      onNext: () => context.go(AppRoutes.preferencesLeagues),
      nextLabel: draft.teams.isEmpty ? "Continue" : "Continue (${draft.teams.length} selected)",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onQueryChanged,
            style: AppTypography.body,
            decoration: AppComponentStyles.textField(
              label: "Search teams",
              hint: "e.g. Real Madrid",
              suffixIcon: const Icon(Icons.search, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (draft.teams.isNotEmpty) ...[
            Text("Selected", style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: draft.teams
                  .map((t) => _SelectedChip(label: t.name, onRemove: () => draftNotifier.toggleTeam(t)))
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
              child: Text("No teams found for \"${_searchController.text.trim()}\".",
                  style: AppTypography.bodyMuted),
            )
          else
            ..._results.map((team) {
              final selected = draftNotifier.hasTeam(team.id);
              return _TeamTile(team: team, selected: selected, onTap: () => draftNotifier.toggleTeam(team));
            }),
        ],
      ),
    );
  }
}

class _TeamTile extends StatelessWidget {
  final Team team;
  final bool selected;
  final VoidCallback onTap;
  const _TeamTile({required this.team, required this.selected, required this.onTap});

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
                  team.logo,
                  width: 32,
                  height: 32,
                  errorBuilder: (_, _, _) => const Icon(Icons.shield_outlined, color: AppColors.textMuted),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(team.name, style: AppTypography.body),
                      if (team.country != null) Text(team.country!, style: AppTypography.caption),
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
