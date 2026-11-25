import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/features/home/widgets/custom_circle_button.dart';
import 'package:mobile/generated/style_atoms.dart';

class HomeAppBar extends StatefulWidget {
  final String? selectedCity;
  final String? selectedCountry;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onMessagesTap;

  const HomeAppBar({
    super.key,
    this.selectedCity,
    this.selectedCountry,
    required this.onLocationTap,
    required this.onNotificationTap,
    required this.onMessagesTap,
  });

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.home;
    final l = context.t.location;
    final colorScheme = context.colorScheme;

    final bool hasLocation =
        widget.selectedCity != null && widget.selectedCity!.isNotEmpty;

    final String locationText = hasLocation
        ? '${widget.selectedCity}،\n${widget.selectedCountry ?? ''}'
        : l.select_location_hint;

    return Container(
      height: 75.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: colorScheme.surface,
      child: Row(
        children: [
          Text(
            t.app_name_ar,
            style: context.bold14.copyWith(color: colorScheme.primary),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Container(
              width: 1.w,
              height: 16.h,
              color: colorScheme.outlineVariant,
            ),
          ),
          Text(
            t.app_name_en,
            style: context.bold16.copyWith(color: colorScheme.onSurface),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return InkWell(
                    onTap: widget.onLocationTap,
                    borderRadius: BorderRadius.circular(24.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          colorScheme.surface,
                          colorScheme.surfaceContainerLow,
                          hasLocation ? 0.2 : _pulseAnimation.value * 0.85,
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Color.lerp(
                            colorScheme.outlineVariant,
                            colorScheme.primary,
                            hasLocation ? 0.35 : _pulseAnimation.value,
                          )!,
                          width: hasLocation
                              ? 1.w
                              : (1.w + _pulseAnimation.value * 0.8),
                        ),
                        boxShadow: hasLocation
                            ? []
                            : [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: .28 * _pulseAnimation.value,
                                  ),
                                  blurRadius: 10 * _pulseAnimation.value,
                                  spreadRadius: 1.5 * _pulseAnimation.value,
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16.sp,
                            color: hasLocation
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.primary,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              locationText,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: hasLocation
                                  ? context.semiBold12.copyWith(
                                      color: colorScheme.onSurface,
                                    )
                                  : context.semiBold12.copyWith(
                                      color: colorScheme.primary,
                                    ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16.sp,
                            color: hasLocation
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(width: 8.w),

          CircleIconButton(
            icon: Icons.notifications_none_outlined,
            onTap: widget.onNotificationTap,
          ),
          SizedBox(width: 8.w),
          CircleIconButton(
            icon: Icons.mail_outline,
            onTap: widget.onMessagesTap,
          ),
        ],
      ),
    );
  }
}