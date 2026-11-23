import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/home/models/suggestion_item_model.dart';
import 'package:mobile/generated/style_atoms.dart';

class SelectedPlaceMapCard extends StatelessWidget {
  final SuggestionItemModel place;
  final double distanceKm;
  final VoidCallback onClose;

  const SelectedPlaceMapCard({
    super.key,
    required this.place,
    required this.distanceKm,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12.w,
      right: 12.w,
      bottom: 12.h,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: place.badgeBgColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  place.categoryEmoji,
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    place.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bold12TextMain,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${place.location} • $distanceKm كم',
                    style: context.regular12TextSub,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18.sp,
                color: AppColors.textSub,
              ),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}