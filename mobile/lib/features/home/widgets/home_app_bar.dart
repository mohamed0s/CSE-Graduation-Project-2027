import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/generated/style_atoms.dart';

class HomeAppBar extends StatelessWidget {
  final String currentCity;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onMessagesTap;

  const HomeAppBar({
    super.key,
    required this.currentCity,
    required this.onLocationTap,
    required this.onNotificationTap,
    required this.onMessagesTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.home;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: AppColors.white,
      child: Row(
        children: [
          Text(t.app_name_ar, style: context.bold16Primary),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Container(
              width: 1.w,
              height: 16.h,
              color: AppColors.borderLight,
            ),
          ),
          Text(t.app_name_en, style: context.bold14TextMain),

          const Spacer(),

          InkWell(
            onTap: onLocationTap,
            borderRadius: BorderRadius.circular(24.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined, size: 16.sp, color: AppColors.textSub),
                  SizedBox(width: 4.w),
                  Text(
                    currentCity,
                    textAlign: TextAlign.center,
                    style: context.semiBold12TextMain,
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.keyboard_arrow_down, size: 16.sp, color: AppColors.textSub),
                ],
              ),
            ),
          ),

          const Spacer(),

          // زر الإشعارات
          _CircleIconButton(
            icon: Icons.notifications_none_outlined,
            onTap: onNotificationTap,
          ),
          SizedBox(width: 8.w),

          // زر الرسائل
          _CircleIconButton(
            icon: Icons.mail_outline,
            onTap: onMessagesTap,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Icon(icon, size: 18.sp, color: AppColors.textSub),
      ),
    );
  }
}