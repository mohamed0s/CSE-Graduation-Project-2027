import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/utils/app_images.dart';
import 'package:mobile/core/widgets/buttons/social_button.dart';

class SocialAuthButtons extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onAppleTap;

  const SocialAuthButtons({super.key, this.onGoogleTap, this.onAppleTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SocialButton(
          text: 'Google',
          iconPath: AppImages.googleIcon,
          onTap: onGoogleTap ?? () {},
        ),
        SizedBox(width: 16.w),
        SocialButton(
          text: 'Apple',
          iconPath: AppImages.appleIcon,
          onTap: onAppleTap ?? () {},
        ),
      ],
    );
  }
}
