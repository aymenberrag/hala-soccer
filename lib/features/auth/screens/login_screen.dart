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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final error = await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });
    // On success, the router's redirect (driven by AuthController state)
    // takes over navigation to Home automatically.
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
                const SizedBox(height: AppSpacing.xl),
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(gradient: AppColors.brandGradient, shape: BoxShape.circle),
                  child: const Icon(Icons.sports_soccer, color: Colors.white, size: 32),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text("Welcome back", style: AppTypography.h1),
                const SizedBox(height: AppSpacing.xs),
                const Text("Log in to keep up with your teams.", style: AppTypography.bodyMuted),
                const SizedBox(height: AppSpacing.xl),
                if (_error != null) AppErrorBanner(message: _error!),
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
                  textInputAction: TextInputAction.done,
                  validator: (v) => (v == null || v.isEmpty) ? "Enter your password" : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading ? null : () => context.push(AppRoutes.forgotPassword),
                    child: const Text("Forgot password?"),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  style: AppComponentStyles.primaryButton,
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandNavyDark),
                        )
                      : const Text("Log In"),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", style: AppTypography.bodyMuted),
                    TextButton(
                      onPressed: _loading ? null : () => context.go(AppRoutes.signup),
                      child: const Text("Sign Up"),
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
