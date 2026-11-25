import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/generated/style_atoms.dart';

class QuickCategoriesSection extends StatelessWidget {
  final int selectedCategoryIndex;
  final ValueChanged<int> onCategorySelect;


  const QuickCategoriesSection({
    super.key,
    required this.selectedCategoryIndex,
    required this.onCategorySelect,
    
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.home;
    final colorScheme = context.colorScheme;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    final categories = [
      (label: t.all, emoji: null, icon: Icons.grid_view_rounded),
      (label: t.restaurants_food, emoji: '🍔', icon: null),
      (label: t.maintenance_services, emoji: '🔧', icon: null),
      (label: t.Health_clinics, emoji: '🏥', icon: null),
      (label: t.Property_rentals, emoji: '🏡', icon: null),
      (label: t.Banks_ATMs, emoji: '🏦', icon: null),
      (label: t.Supermarkets, emoji: '🍫', icon: null),
      (label: t.Public_services, emoji: '🏛', icon: null),
      (label: t.Shops, emoji: '🛒', icon: null),
      (label: t.Places_of_worship, emoji: '🕌', icon: null),
    ];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.quick_categories,
                style: context.bold14.copyWith(color: colorScheme.onSurface),
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
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (item.icon != null)
                        Icon(
                          item.icon,
                          size: 18.sp,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.primary,
                        )
                      else if (item.emoji != null)
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: bgColor,
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
                            ? context.semiBold12.copyWith(
                                color: colorScheme.onPrimary,
                              )
                            : context.semiBold12.copyWith(
                                color: colorScheme.onSurface,
                              ),
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