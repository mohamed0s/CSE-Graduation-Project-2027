import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/generated/style_atoms.dart';

class QuickCategoriesSection extends StatelessWidget {
  final int selectedCategoryIndex;
  final ValueChanged<int> onCategorySelect;
  final VoidCallback onViewAllTap;

  const QuickCategoriesSection({
    super.key,
    required this.selectedCategoryIndex,
    required this.onCategorySelect,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.home;

    final categories = [
      (label: t.all, emoji: null, icon: Icons.grid_view_rounded),
      (label: t.restaurants_food, emoji: '🍔', icon: null),
      (label: t.maintenance_services, emoji: '🔧', icon: null),
    ];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.quick_categories, style: context.bold14TextMain),
              GestureDetector(
                onTap: onViewAllTap,
                child: Text(t.view_all, style: context.semiBold12TextLink),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 48.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: categories.length,
            separatorBuilder: (context, i) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final isSelected = selectedCategoryIndex == index;
              final item = categories[index];

              return GestureDetector(
                onTap: () => onCategorySelect(index),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (item.icon != null)
                        Icon(
                          item.icon,
                          size: 18.sp,
                          color: isSelected
                              ? AppColors.warningLight
                              : AppColors.primary,
                        )
                      else if (item.emoji != null)
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            item.emoji!,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      SizedBox(width: 8.w),
                      Text(
                        item.label,
                        style: isSelected
                            ? context.semiBold12White
                            : context.semiBold12TextMain,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
