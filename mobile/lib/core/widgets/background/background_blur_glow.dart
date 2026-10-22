import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/app_colors.dart';

class CustomBackgroundGlow extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double? width;
  final double? height;
  final List<Color>? colors;

  const CustomBackgroundGlow({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.width,
    this.height,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: width ?? 200.w,
        height: height ?? 200.h,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: _getAlignment(),
            radius: 1.2,
            colors:
                colors ??
                [
                  const Color(0xFF38CBB0).withOpacity(0.85),
                  const Color(0xFF38CBB0).withOpacity(0.3),
                  AppColors.backgroundLight.withOpacity(0.0),
                ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }

  Alignment _getAlignment() {
    if (top != null && left != null) return Alignment.topLeft;
    if (top != null && right != null) return Alignment.topRight;
    if (bottom != null && left != null) return Alignment.bottomLeft;
    if (bottom != null && right != null) return Alignment.bottomRight;
    return Alignment.topRight; // Default
  }
}
