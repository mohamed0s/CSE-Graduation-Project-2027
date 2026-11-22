import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/features/home/models/suggestion_item_model.dart';
import 'package:mobile/generated/style_atoms.dart';

class SuggestionCard extends StatelessWidget {
  final SuggestionItemModel item;
  final VoidCallback? onTap;

  const SuggestionCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.home;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                     
                        SizedBox(
                          width: 150.w,
                          child: Text(
                            item.title,
                            style: context.bold14TextMain,
                          maxLines: 3,
                          
                                                ),
                        ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: item.badgeBgColor,
                          borderRadius: BorderRadius.circular(8.r),
                          border: item.badgeBorderColor != null
                              ? Border.all(color: item.badgeBorderColor!)
                              : null,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          
                          children: [
                            Text(
                              item.categoryLabel,
                              style: TextStyle(
                                fontFamily: 'Almarai',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: item.badgeTextColor,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(item.categoryEmoji, style: TextStyle(fontSize: 11.sp)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  if (item.subtitle.isNotEmpty)
                    Text(
                      item.subtitle,
                      style: context.regular12TextSub,
                    ),
                  if (item.price != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      t.price_per_month(price: item.price!),
                      style: context.bold12TextLink,
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
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.danger.withValues(alpha: .5)),
                  ),
                  child: Text(
                    t.distance_km(distance: item.distance),
                    style: context.semiBold11Danger,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item.location,
                  style: context.regular12TextSub,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}