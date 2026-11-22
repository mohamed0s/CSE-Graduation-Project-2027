import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/generated/style_atoms.dart';

class PromoBannerSlider extends StatefulWidget {
  final String cityName;

  const PromoBannerSlider({super.key, required this.cityName});

  @override
  State<PromoBannerSlider> createState() => _PromoBannerSliderState();
}

class _PromoBannerSliderState extends State<PromoBannerSlider> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.home;

    return Column(
      children: [
        SizedBox(
          height: 255.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 2,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: AppColors.white,
                  gradient: RadialGradient(
                    center: LocaleSettings.currentLocale == AppLocale.ar? Alignment.topLeft:Alignment.topRight,
                    radius: .5,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.5),
                      AppColors.primary.withValues(alpha: 0.35),
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.45, 0.8, 1.0],
                  ),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: .3),
                        ),
                      ),
                      child: Text(
                        t.banner_badge(city: widget.cityName),
                        style: context.semiBold12TextLink,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    Text(
                      t.banner_title,
                      textAlign: TextAlign.center,
                      style: context.bold18TextMain,
                    ),
                    SizedBox(height: 5.h),

                    Text('🗺️', style: TextStyle(fontSize: 22.sp)),
                    SizedBox(height: 5.h),

                    Text(
                      t.banner_subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: context.regular12TextSub,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: isActive ? 18.w : 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.iconColor.withValues(alpha: .4),
                borderRadius: BorderRadius.circular(6.r),
              ),
            );
          }),
        ),
      ],
    );
  }
}
