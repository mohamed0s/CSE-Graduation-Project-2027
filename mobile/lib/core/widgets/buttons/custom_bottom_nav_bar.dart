import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/generated/style_atoms.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String? userName;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.nav;

    return SizedBox(
      height: 70.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            clipBehavior: Clip.none,
            height: 70.h,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: context.colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  icon: Icons.home_mini_rounded,
                  activeIcon: Icons.home_outlined,
                  label: t.home,
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: t.services,
                ),
                SizedBox(width: 65.w),
                _buildNavItem(
                  context: context,
                  index: 3,
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart,
                  label: t.orders,
                ),
                _buildNavItem(
                  context: context,
                  index: 4,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: userName ?? t.profile,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 11.h,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 62.w,
                    height: 62.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.colorScheme.primary.withValues(alpha: 0.8),
                          context.colorScheme.primary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.colorScheme.primary
                              .withValues(alpha: .35),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.smart_toy_outlined,
                      color: context.colorScheme.onPrimary,
                      size: 30.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    t.finda_ai,
                    style: context.semiBold12.copyWith(
                      color: context.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurfaceVariant,
              size: 30.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: isSelected
                  ? context.semiBold12.copyWith(
                      color: context.colorScheme.primary,
                    )
                  : context.medium12.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
