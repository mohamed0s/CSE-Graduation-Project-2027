import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/utils/extensions.dart';

class PulsingLocationMarker extends StatelessWidget {
  final AnimationController controller;

  const PulsingLocationMarker({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = controller.value;

        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 1 + (value * 0.9),
              child: Opacity(
                opacity: (1 - value).clamp(0.0, 1.0),
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.onPrimary,
                  width: 3.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}