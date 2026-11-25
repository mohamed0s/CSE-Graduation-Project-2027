import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/generated/style_atoms.dart';

class PromoBannerCard extends StatelessWidget {
  final String badgeText;
  final String title;
  final String subtitle;

  const PromoBannerCard({
    super.key,
    required this.badgeText,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: colorScheme.surface,
        gradient: RadialGradient(
          center: LocaleSettings.currentLocale == AppLocale.ar
              ? Alignment.topLeft
              : Alignment.topRight,
          radius: .5,
          colors: [
            colorScheme.primary.withValues(alpha: 0.5),
            colorScheme.primary.withValues(alpha: 0.35),
            colorScheme.primary.withValues(alpha: 0.2),
            colorScheme.primary.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45, 0.8, 1.0],
        ),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: .3),
              ),
            ),
            child: Text(
              badgeText,
              style: context.semiBold12.copyWith(color: colorScheme.primary),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.bold18.copyWith(color: colorScheme.onSurface),
          ),
          SizedBox(height: 5.h),
          Text('🗺️', style: TextStyle(fontSize: 22.sp)),
          SizedBox(height: 5.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.regular12.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}