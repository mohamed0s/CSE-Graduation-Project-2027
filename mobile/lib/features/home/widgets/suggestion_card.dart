import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/features/home/models/suggestion_item_model.dart';
import 'package:mobile/generated/style_atoms.dart';

class SuggestionCard extends StatelessWidget {
  final SuggestionItemModel item;
  final VoidCallback? onTap;

  const SuggestionCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.t.home;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: context.bold14.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: item.badgeBgColor,
                          borderRadius: BorderRadius.circular(8.r),
                          border: item.badgeBorderColor != null
                              ? Border.all(color: item.badgeBorderColor!)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.categoryLabel,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: item.badgeTextColor,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              item.categoryEmoji,
                              style: TextStyle(fontSize: 11.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  if (item.subtitle.isNotEmpty)
                    Text(
                      item.subtitle,
                      style: context.regular12.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (item.price != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      t.price_per_month(price: item.price!),
                      style: context.bold12.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: 10.w),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: colorScheme.error.withValues(alpha: .5),
                    ),
                  ),
                  child: Text(
                    t.distance_km(distance: item.distance),
                    style: context.semiBold11.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item.location,
                  style: context.regular12.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}