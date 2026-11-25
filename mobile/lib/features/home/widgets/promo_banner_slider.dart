import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'promo_banner_card.dart';

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
    final colorScheme = context.colorScheme;

    final banners = [
      PromoBannerCard(
        badgeText: t.banner_badge1(city: widget.cityName),
        title: t.banner_title1,
        subtitle: t.banner_subtitle1,
      ),
      PromoBannerCard(
        badgeText: t.banner_badge2,
        title: t.banner_title2(city: widget.cityName),
        subtitle: t.banner_subtitle2,
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 255.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => banners[index],
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: isActive ? 18.w : 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: .4),
                borderRadius: BorderRadius.circular(6.r),
              ),
            );
          }),
        ),
      ],
    );
  }
}