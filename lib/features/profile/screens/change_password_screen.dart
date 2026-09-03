import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../shared/widgets/app_password_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;
  String? _error;
  bool _done = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_newController.text != _confirmController.text) {
      setState(() => _error = "New passwords don't match.");
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ProfileRepository().changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _done = true;
      });
    } on ApiException catch (e) {
      setState(() {
        _saving = false;
        _error = e.fieldErrors?["current_password"] as String? ?? e.message;
      });
    } catch (e) {
      setState(() {
        _saving = false;
        _error = "Something went wrong. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _done
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.brandGreenBright, size: 56),
                  const SizedBox(height: AppSpacing.md),
                  Text("Password updated", style: AppTypography.h2),
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Done")),
                ],
              )
            : ListView(
                children: [
                  if (_error != null) ...[
                    Text(_error!, style: AppTypography.body.copyWith(color: AppColors.error)),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AppPasswordField(controller: _currentController, label: "Current password"),
                  const SizedBox(height: AppSpacing.md),
                  AppPasswordField(controller: _newController, label: "New password"),
                  const SizedBox(height: AppSpacing.md),
                  AppPasswordField(controller: _confirmController, label: "Confirm new password"),
                  const SizedBox(height: AppSpacing.xl),
                  ElevatedButton(
                    style: AppComponentStyles.primaryButton,
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandNavyDark))
                        : const Text("Update Password"),
                  ),
                ],
              ),
      ),
    );
  }
}
