import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../preferences_draft_controller.dart';
import 'onboarding_step_scaffold.dart';

const _genders = [
  (value: "male", label: "Male"),
  (value: "female", label: "Female"),
  (value: "prefer_not_to_say", label: "Prefer not to say"),
];

/// Step 1 of 3 in spec section 3's onboarding: only what's actually
/// useful for AI curation (country informs relevant local football;
/// age/gender are optional and easy to skip).
class UserInfoScreen extends ConsumerStatefulWidget {
  const UserInfoScreen({super.key});

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  late final _countryController =
      TextEditingController(text: ref.read(preferencesDraftProvider).country);
  late final _ageController = TextEditingController(
    text: ref.read(preferencesDraftProvider).age?.toString() ?? "",
  );
  String? _gender;

  @override
  void initState() {
    super.initState();
    _gender = ref.read(preferencesDraftProvider).gender;
  }

  @override
  void dispose() {
    _countryController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _next() {
    ref.read(preferencesDraftProvider.notifier).setInfo(
          country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
          age: int.tryParse(_ageController.text.trim()),
          gender: _gender,
        );
    context.go(AppRoutes.preferencesTeams);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      step: 1,
      totalSteps: 3,
      title: "Tell us about you",
      subtitle: "A little context helps Hala highlight the football that matters to you.",
      onSkip: _next,
      onNext: _next,
      nextLabel: "Continue",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _countryController,
            style: AppTypography.body,
            decoration: AppComponentStyles.textField(label: "Country", hint: "e.g. Algeria"),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            style: AppTypography.body,
            decoration: AppComponentStyles.textField(label: "Age (optional)", hint: "e.g. 24"),
          ),
          const SizedBox(height: AppSpacing.md),
          Text("Gender (optional)", style: AppTypography.bodyMuted),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _genders.map((g) {
              final selected = _gender == g.value;
              return ChoiceChip(
                label: Text(g.label),
                selected: selected,
                onSelected: (_) => setState(() => _gender = selected ? null : g.value),
                selectedColor: AppColors.brandGreenBright,
                backgroundColor: AppColors.surfaceElevated,
                labelStyle: AppTypography.body.copyWith(
                  color: selected ? AppColors.brandNavyDark : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
                side: const BorderSide(color: AppColors.divider),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
