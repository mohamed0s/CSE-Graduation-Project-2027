import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/features/services/models/category_model.dart';
import 'package:mobile/generated/style_atoms.dart';

class ServiceCategoryCard extends StatelessWidget {
final CategoryModel category;
  final VoidCallback? onTap;

  const ServiceCategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: colorScheme.outlineVariant),
          gradient: RadialGradient(
            center: LocaleSettings.currentLocale == AppLocale.ar
                ? Alignment.topRight
                : Alignment.topLeft,
            radius: .7,
            colors: [
              colorScheme.primary.withValues(alpha: isDark ? 0.6 : 0.5),
              colorScheme.primary.withValues(alpha: 0.35),
              colorScheme.primary.withValues(alpha: 0.2),
              colorScheme.primary.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.45, 0.8, 1.0],
          ),
          
          // boxShadow: [
          //   BoxShadow(
          //     color: colorScheme.shadow.withValues(alpha: 0.04),
          //     blurRadius: 8,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(category.icon, color: colorScheme.primary, size: 20.sp),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    category.badgeText,
                    textAlign: TextAlign.center,
                    style: context.semiBold11.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
           SizedBox(height: 8.h,),
            Text(
              category.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bold14.copyWith(color: colorScheme.onSurface),
            ),
            SizedBox(height: 2.h),
            Text(
              category.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.regular12.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
