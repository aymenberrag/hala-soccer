import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../auth/auth_controller.dart';

const _genders = [
  (value: "male", label: "Male"),
  (value: "female", label: "Female"),
  (value: "prefer_not_to_say", label: "Prefer not to say"),
];

Future<void> showEditPersonalInfoSheet(BuildContext context, WidgetRef ref) {
  final user = ref.read(authControllerProvider).user;
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => _EditPersonalInfoSheet(
      country: user?.country,
      age: user?.age,
      gender: user?.gender,
    ),
  );
}

class _EditPersonalInfoSheet extends ConsumerStatefulWidget {
  final String? country;
  final int? age;
  final String? gender;
  const _EditPersonalInfoSheet({this.country, this.age, this.gender});

  @override
  ConsumerState<_EditPersonalInfoSheet> createState() => _EditPersonalInfoSheetState();
}

class _EditPersonalInfoSheetState extends ConsumerState<_EditPersonalInfoSheet> {
  late final _countryController = TextEditingController(text: widget.country);
  late final _ageController = TextEditingController(text: widget.age?.toString() ?? "");
  late String? _gender = widget.gender;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _countryController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final user = await ProfileRepository().updatePersonalInfo(
        country: _countryController.text.trim().isEmpty ? "" : _countryController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        gender: _gender,
      );
      ref.read(authControllerProvider.notifier).setUser(user);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Personal Information", style: AppTypography.h2),
          const SizedBox(height: AppSpacing.lg),
          if (_error != null) ...[
            Text(_error!, style: AppTypography.body.copyWith(color: AppColors.error)),
            const SizedBox(height: AppSpacing.md),
          ],
          TextField(
            controller: _countryController,
            decoration: AppComponentStyles.textField(label: "Country"),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: AppComponentStyles.textField(label: "Age"),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
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
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppComponentStyles.primaryButton,
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandNavyDark))
                  : const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }
}
