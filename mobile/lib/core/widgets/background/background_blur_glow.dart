import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum GlowPreset { soft, medium, strong }

class CustomBackgroundGlow extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  final double? width;
  final double? height;

  final Color color;
  final List<Color>? colors;

  final GlowPreset preset;
  final Alignment? center;
  final double radius;

  const CustomBackgroundGlow({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.width,
    this.height,
    this.color = const Color(0xFF38CBB0),
    this.colors,
    this.preset = GlowPreset.soft,
    this.center,
    this.radius = 1.2,
  }) : assert(colors == null || colors.length == 3);

  // Ready-made corner positions

  CustomBackgroundGlow.topLeft({
    Key? key,
    double top = 0,
    double left = 0,
    double size = 280,
    GlowPreset preset = GlowPreset.soft,
    Color color = const Color(0xFF38CBB0),
  }) : this(
         key: key,
         top: top,
         left: left,
         width: size.w,
         height: size.h,
         center: Alignment.topLeft,
         preset: preset,
         color: color,
       );

  CustomBackgroundGlow.topRight({
    Key? key,
    double top = 0,
    double right = 0,
    double size = 280,
    GlowPreset preset = GlowPreset.soft,
    Color color = const Color(0xFF38CBB0),
  }) : this(
         key: key,
         top: top,
         right: right,
         width: size.w,
         height: size.h,
         center: Alignment.topRight,
         preset: preset,
         color: color,
       );

  CustomBackgroundGlow.bottomLeft({
    Key? key,
    double bottom = 0,
    double left = 0,
    double size = 280,
    GlowPreset preset = GlowPreset.soft,
    Color color = const Color(0xFF38CBB0),
  }) : this(
         key: key,
         bottom: bottom,
         left: left,
         width: size.w,
         height: size.h,
         center: Alignment.bottomLeft,
         preset: preset,
         color: color,
       );

  CustomBackgroundGlow.bottomRight({
    Key? key,
    double bottom = 0,
    double right = 0,
    double size = 280,
    GlowPreset preset = GlowPreset.soft,
    Color color = const Color(0xFF38CBB0),
  }) : this(
         key: key,
         bottom: bottom,
         right: right,
         width: size.w,
         height: size.h,
         center: Alignment.bottomRight,
         preset: preset,
         color: color,
       );

  List<Color> get _glowColors {
    final opacities = switch (preset) {
      GlowPreset.soft => [0.20, 0.08],
      GlowPreset.medium => [0.38, 0.15],
      GlowPreset.strong => [0.65, 0.25],
    };

    return [
      color.withOpacity(opacities[0]),
      color.withOpacity(opacities[1]),
      color.withOpacity(0),
    ];
  }

  Alignment _getAlignment() {
    if (top != null && left != null) {
      return Alignment.topLeft;
    }

    if (top != null && right != null) {
      return Alignment.topRight;
    }

    if (bottom != null && left != null) {
      return Alignment.bottomLeft;
    }

    if (bottom != null && right != null) {
      return Alignment.bottomRight;
    }

    return Alignment.topRight;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: width ?? 260.w,
          height: height ?? 260.h,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.r),
            gradient: RadialGradient(
              center: center ?? _getAlignment(),
              radius: radius,
              colors: colors ?? _glowColors,
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
