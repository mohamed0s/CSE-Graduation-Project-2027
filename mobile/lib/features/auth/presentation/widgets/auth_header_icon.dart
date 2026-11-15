import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/app_colors.dart';

class AuthHeaderIcon extends StatelessWidget {
  final double size;
  final double iconSize;
  final IconData icon;

  const AuthHeaderIcon({
    super.key,
    this.size = 80,
    this.iconSize = 40,
    this.icon = Icons.lock_reset_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
      ),
      child: Center(
        child: Icon(icon, size: iconSize.sp, color: AppColors.primary),
      ),
    );
  }
}
