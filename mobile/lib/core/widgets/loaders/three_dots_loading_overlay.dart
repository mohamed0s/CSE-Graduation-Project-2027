import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/app_colors.dart';

class ThreeDotsLoadingOverlay extends StatefulWidget {
  const ThreeDotsLoadingOverlay({super.key});

  @override
  State<ThreeDotsLoadingOverlay> createState() =>
      _ThreeDotsLoadingOverlayState();
}

class _ThreeDotsLoadingOverlayState extends State<ThreeDotsLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.black.withValues(alpha: .8), 
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      
                      final double delay = index * 0.2;
                      final double value =
                          ((_controller.value - delay) % 1.0 + 1.0) % 1.0;
                      final double scale = value < 0.5
                          ? 0.6 + (value * 1.2)
                          : 1.2 - ((value - 0.5) * 1.2);

                      return Transform.scale(
                        scale: scale.clamp(0.6, 1.2),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          width: 9.w,
                          height: 9.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 
                              (scale / 1.2).clamp(0.4, 1.0),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}