import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/generated/style_atoms.dart';

class ServicesSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const ServicesSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.services;
    final colorScheme = context.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 18.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: SizedBox(
              height: 38.h,
              child: Center(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: context.regular12.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 2.w,vertical: 8.h),
                    isDense: true,
                    border: InputBorder.none,
                    hintText: t.search_hint,
                    hintStyle: context.regular11.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Icon(Icons.search_rounded, color: colorScheme.primary, size: 22.sp),
        ],
      ),
    );
  }
}
