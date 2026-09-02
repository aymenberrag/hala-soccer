import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_component_styles.dart';

class AppPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const AppPasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.validator,
    this.textInputAction,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      style: const TextStyle(color: AppColors.textPrimary),
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      decoration: AppComponentStyles.textField(
        label: widget.label,
        errorText: widget.errorText,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textMuted,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
