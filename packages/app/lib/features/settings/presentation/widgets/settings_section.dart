import 'package:core_ui/theme/app_colors.dart';
import 'package:core_ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Widget para cabeçalho de seção em Settings
/// Design: Ícone + Título em negrito
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.icon,
    super.key,
  });
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
