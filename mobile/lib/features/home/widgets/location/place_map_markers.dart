import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/app_colors.dart';

class PlaceMapMarker extends StatelessWidget {
  final String emoji;
  final bool isNearby;
  final bool isSelected;
  final VoidCallback onTap;

  const PlaceMapMarker({
    super.key,
    required this.emoji,
    required this.isNearby,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.white
        : (isNearby ? AppColors.primary : AppColors.textSub);

    final pinColor = isSelected
        ? AppColors.primary
        : (isNearby ? AppColors.primary : AppColors.textSub);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 38.w : 32.w,
            height: isSelected ? 38.w : 32.w,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2.5 : 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(fontSize: isSelected ? 16.sp : 14.sp),
              ),
            ),
          ),
          Container(
            width: 3.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: pinColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.r)),
            ),
          ),
        ],
      ),
    );
  }
}