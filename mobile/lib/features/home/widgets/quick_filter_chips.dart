import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/generated/style_atoms.dart';

class QuickFilterChips extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const QuickFilterChips({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.home;

    final chips = [
      (label: t.discover, icon: Icons.search),
      (label: t.finda_ai, icon: Icons.smart_toy_outlined),
      (label: t.my_orders, icon: Icons.shopping_cart_outlined),
      (label: t.craftsmen, icon: null),
    ];

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(bottom: 12.h, top: 4.h),
      height: 48.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: chips.length,
        separatorBuilder: (context, i) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final chip = chips[index];

          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w,vertical: 5.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.secondary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  if (chip.icon != null) ...[
                    Icon(
                      chip.icon,
                      size: 16.sp,
                      color: isSelected ? AppColors.white : AppColors.textSub,
                    ),
                    SizedBox(width: 6.w),
                  ],
                  Text(
                    chip.label,
                    style: isSelected
                        ? context.semiBold12White
                        : context.medium12TextSub,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}