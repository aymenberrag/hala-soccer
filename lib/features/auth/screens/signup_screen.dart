import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_error_banner.dart';
import '../../../shared/widgets/app_password_field.dart';
import '../auth_controller.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final error = await ref.read(authControllerProvider.notifier).signup(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmController.text,
        );

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                const Text("Create your account", style: AppTypography.h1),
                const SizedBox(height: AppSpacing.xs),
                const Text("Join Hala Soccer and never miss a match.", style: AppTypography.bodyMuted),
                const SizedBox(height: AppSpacing.xl),
                if (_error != null) AppErrorBanner(message: _error!),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: AppComponentStyles.textField(label: "Full name"),
                  validator: (v) => (v == null || v.trim().length < 2) ? "Enter your name" : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: AppComponentStyles.textField(label: "Email"),
                  validator: (v) => (v == null || !v.contains("@")) ? "Enter a valid email" : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppPasswordField(
                  controller: _passwordController,
                  label: "Password",
                  validator: (v) =>
                      (v == null || v.length < 8) ? "At least 8 characters, with a letter & number" : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppPasswordField(
                  controller: _confirmController,
                  label: "Confirm password",
                  textInputAction: TextInputAction.done,
                  validator: (v) => (v != _passwordController.text) ? "Passwords don't match" : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  style: AppComponentStyles.primaryButton,
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandNavyDark),
                        )
                      : const Text("Create Account"),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?", style: AppTypography.bodyMuted),
                    TextButton(
                      onPressed: _loading ? null : () => context.go(AppRoutes.login),
                      child: const Text("Log In"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
