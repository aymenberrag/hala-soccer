import 'package:flutter/material.dart';

import '../../../core/network/backend_api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_component_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_error_banner.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await BackendApiClient.instance.post(
        "/api/auth/forgot-password",
        auth: false,
        body: {"email": _emailController.text.trim()},
      );
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Reset password")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _sent
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mark_email_read_outlined, size: 56, color: AppColors.brandGreenBright),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "If ${_emailController.text.trim()} is registered, a reset link is on its way.",
                      textAlign: TextAlign.center,
                      style: AppTypography.body,
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Enter the email on your account and we'll send a reset link.",
                        style: AppTypography.bodyMuted,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (_error != null) AppErrorBanner(message: _error!),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: AppComponentStyles.textField(label: "Email"),
                        validator: (v) => (v == null || !v.contains("@")) ? "Enter a valid email" : null,
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
                            : const Text("Send Reset Link"),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
