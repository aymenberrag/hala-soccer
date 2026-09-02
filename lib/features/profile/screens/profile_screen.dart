import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Profile")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(gradient: AppColors.brandGradient, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : "?",
                          style: AppTypography.display,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(user?.name ?? "—", style: AppTypography.h2),
                    Text(user?.email ?? "", style: AppTypography.bodyMuted),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _MenuTile(icon: Icons.lock_outline, label: "Change password", onTap: () {}),
              _MenuTile(icon: Icons.notifications_outlined, label: "Notifications", onTap: () {}),
              _MenuTile(icon: Icons.help_outline, label: "Help & support", onTap: () {}),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    minimumSize: const Size.fromHeight(52),
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    textStyle: AppTypography.button,
                  ),
                  onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                  child: const Text("Log Out"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(label, style: AppTypography.body)),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
