import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum StatusPillType { success, warning, error, info, neutral }

class StatusPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final StatusPillType type;
  final bool isSolid;

  const StatusPill({
    super.key,
    required this.label,
    this.icon,
    this.type = StatusPillType.info,
    this.isSolid = false,
  });

  @override
  Widget build(BuildContext context) {
    Color baseColor;
    Color lightColor;

    switch (type) {
      case StatusPillType.success:
        baseColor = AppColors.success;
        lightColor = AppColors.successLight;
        break;
      case StatusPillType.warning:
        baseColor = AppColors.warning;
        lightColor = AppColors.warningLight;
        break;
      case StatusPillType.error:
        baseColor = AppColors.error;
        lightColor = AppColors.errorLight;
        break;
      case StatusPillType.info:
        baseColor = AppColors.info;
        lightColor = AppColors.infoLight;
        break;
      case StatusPillType.neutral:
        baseColor = Colors.grey.shade700;
        lightColor = Colors.grey.shade100;
        break;
    }

    final backgroundColor = isSolid ? baseColor : lightColor;
    final textColor = isSolid ? Colors.white : baseColor;
    final borderColor = isSolid ? baseColor : baseColor.withValues(alpha: 0.35);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
