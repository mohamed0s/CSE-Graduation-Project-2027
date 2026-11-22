import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/generated/style_atoms.dart';

class NearbySearchCard extends StatelessWidget {
  final String cityName;
  final bool isListView;
  final bool useCurrentLocation;
  final ValueChanged<bool> onToggleView;
  final ValueChanged<bool?> onLocationCheckChanged;
  final ValueChanged<String> onSearchChanged;

  const NearbySearchCard({
    super.key,
    required this.cityName,
    required this.isListView,
    required this.useCurrentLocation,
    required this.onToggleView,
    required this.onLocationCheckChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.home;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان مع الدبوس
          Row(
            children: [
              Text('📍', style: TextStyle(fontSize: 16.sp)),
              SizedBox(width: 6.w),
              Text(
                t.search_in_city(city: cityName),
                style: context.bold14TextMain,
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // زر التبديل (عرض القائمة / الخريطة)
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ViewToggleButton(
                    label: t.list_view,
                    icon: Icons.format_list_bulleted,
                    isActive: isListView,
                    onTap: () => onToggleView(true),
                  ),
                ),
                Expanded(
                  child: _ViewToggleButton(
                    label: t.map_view,
                    icon: Icons.map_outlined,
                    isActive: !isListView,
                    onTap: () => onToggleView(false),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // حقل البحث
          TextField(
            onChanged: onSearchChanged,
            style: context.regular12TextMain,
            decoration: InputDecoration(
              hintText: t.search_hint,
              hintStyle: context.regular11TextPlaceholder,
              filled: true,
              fillColor: AppColors.backgroundLight,
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // Checkbox تحديد الموقع الحالي
          Row(
            children: [
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: Checkbox(
                  value: useCurrentLocation,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  onChanged: onLocationCheckChanged,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                t.use_current_location,
                style: context.regular12TextSub,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isActive ? AppColors.white : AppColors.textSub,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: isActive ? context.semiBold12White : context.medium12TextSub,
            ),
          ],
        ),
      ),
    );
  }
}