import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/features/home/models/suggestion_item_model.dart';
import 'package:mobile/features/home/widgets/home_app_bar.dart';
import 'package:mobile/features/home/widgets/nearby_search_card.dart';
import 'package:mobile/features/home/widgets/promo_banner_slider.dart';
import 'package:mobile/features/home/widgets/quick_categories_section.dart';
import 'package:mobile/features/home/widgets/quick_filter_chips.dart';
import 'package:mobile/features/home/widgets/suggestion_card.dart';
import 'package:mobile/generated/style_atoms.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedFilterChip = 0;
  int _selectedCategory = 0;
  bool _isListView = true;
  bool _useCurrentLocation = true;

  // بيانات تجريبية مطابقة للتصميم لحين ربطها بالـ API
  final List<SuggestionItemModel> _mockSuggestions = [
    SuggestionItemModel(
      title: 'مطعم مذاق الشام',
      subtitle: 'مطعم سوري • شاورما ومشويات',
      location: 'شارع المحطة',
      distance: '0.8',
      categoryLabel: 'مطعم',
      categoryEmoji: '🍔',
      badgeBgColor: AppColors.warningLight,
      badgeTextColor: AppColors.warning,
    ),
    SuggestionItemModel(
      title: 'المهندس محمد ناصر للتكييف والتبريد',
      subtitle: 'تبريد وتكييف',
      location: 'القومية',
      distance: '1.8',
      categoryLabel: 'صيانة',
      categoryEmoji: '🔧',
      badgeBgColor: AppColors.primaryLight,
      badgeTextColor: AppColors.primary,
    ),
    SuggestionItemModel(
      title: 'دكتور أحمد حسن',
      subtitle: 'استشاري امراض باطنة وسكر',
      location: 'شارع فاروق',
      distance: '3',
      categoryLabel: 'عيادة',
      categoryEmoji: '🏥',
      badgeBgColor: const Color(0xFFEFF6FF),
      badgeTextColor: const Color(0xFF3B82F6),
      badgeBorderColor: const Color(0xFFBFDBFE),
    ),
    SuggestionItemModel(
      title: 'شقة غرفتين_القومية',
      subtitle: '',
      price: '8,000',
      location: 'القومية',
      distance: '1.8',
      categoryLabel: 'ايجارات',
      categoryEmoji: '🏠',
      badgeBgColor: AppColors.successLight,
      badgeTextColor: AppColors.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.t.home;
    const String currentCity = 'الزقازيق';

    return SafeArea(
      child: Column(
        children: [
          // 1. الهيدر العلوي
          HomeAppBar(
            currentCity: '$currentCity،\nمصر',
            onLocationTap: () {},
            onNotificationTap: () {},
            onMessagesTap: () {},
          ),

          // 2. شريط الفلاتر العلوي
          QuickFilterChips(
            selectedIndex: _selectedFilterChip,
            onSelect: (index) => setState(() => _selectedFilterChip = index),
          ),

          // 3. محتوى الصفحة القابل للتمرير
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // البانر الترحيبي
                  const PromoBannerSlider(cityName: currentCity),
                  SizedBox(height: 18.h),

                  // التصنيفات السريعة
                  QuickCategoriesSection(
                    selectedCategoryIndex: _selectedCategory,
                    onCategorySelect: (index) => setState(() => _selectedCategory = index),
                    onViewAllTap: () {},
                  ),
                  SizedBox(height: 18.h),

                  // كارت البحث والخريطة
                  NearbySearchCard(
                    cityName: currentCity,
                    isListView: _isListView,
                    useCurrentLocation: _useCurrentLocation,
                    onToggleView: (isList) => setState(() => _isListView = isList),
                    onLocationCheckChanged: (val) =>
                        setState(() => _useCurrentLocation = val ?? false),
                    onSearchChanged: (query) {},
                  ),
                  SizedBox(height: 20.h),

                  // عنوان مقترحات قريبة منك
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Text('📍', style: TextStyle(fontSize: 16.sp)),
                        SizedBox(width: 6.w),
                        Text(t.nearby_suggestions, style: context.bold14TextMain),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // قائمة الكروت
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _mockSuggestions.length,
                    itemBuilder: (context, index) {
                      return SuggestionCard(
                        item: _mockSuggestions[index],
                        onTap: () {},
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}