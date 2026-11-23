import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/buttons/custom_button.dart';
import 'package:mobile/generated/style_atoms.dart';

class PermissionDialog extends StatelessWidget {
  final bool openAppSettings;
  final VoidCallback onConfirmPressed;

  const PermissionDialog({
    super.key,
    required this.openAppSettings,
    required this.onConfirmPressed,
  });

  static Future<void> show(
    BuildContext context, {
    required bool openAppSettings,
    required VoidCallback onConfirmPressed,
    bool barrierDismissible = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (_) => PermissionDialog(
        openAppSettings: openAppSettings,
        onConfirmPressed: onConfirmPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.location;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(32.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 30.sp,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              t.location_permission_title,
              style: context.bold18TextMain,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              t.location_permission_desc,
              style: context.regular14TextSub,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            CustomAppButton(
              text: openAppSettings
                  ? t.open_settings_btn
                  : t.enable_location_btn,
              onPressed: () {
                Navigator.pop(context);
                onConfirmPressed();
              },
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                t.cancel_btn,
                style: context.medium14TextSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}