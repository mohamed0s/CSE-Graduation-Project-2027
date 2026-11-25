import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/features/home/widgets/nearby_toggle_button.dart';
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
    final colorScheme = context.colorScheme;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('📍', style: TextStyle(fontSize: 16.sp)),
              SizedBox(width: 6.w),
              Text(
                t.search_in_city(city: cityName),
                style: context.bold14.copyWith(color: colorScheme.onSurface),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ViewToggleButton(
                    label: t.list_view,
                    icon: Icons.format_list_bulleted,
                    isActive: isListView,
                    onTap: () => onToggleView(true),
                  ),
                ),
                Expanded(
                  child: ViewToggleButton(
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

          TextField(
            onChanged: onSearchChanged,
            style: context.regular12.copyWith(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: t.search_hint,
              hintStyle: context.regular11.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: bgColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}