import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/generated/style_atoms.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback? onTap;
  final bool isSvg;

  const SocialButton({
    super.key,
    required this.text,
    required this.iconPath,
    this.onTap,
    this.isSvg = true,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isSvg
                  ? SvgPicture.asset(iconPath, width: 24.w, height: 24.h)
                  : Image.asset(iconPath, width: 24.w, height: 24.h),
              SizedBox(width: 12.w),
              Text(text, style: context.bold14Black),
            ],
          ),
        ),
      ),
    );
  }
}
