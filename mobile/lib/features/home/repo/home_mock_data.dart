// for fake data 
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/home/models/suggestion_item_model.dart';

class HomeMockData {
  static List<SuggestionItemModel> getSuggestionsNear(
    double? userLat,
    double? userLng,
  ) {
    final double baseLat = userLat ?? 30.5870;
    final double baseLng = userLng ?? 31.5015;

    return [
      SuggestionItemModel(
        title: 'مطعم مذاق الشام',
        subtitle: 'مطعم سوري • شاورما ومشويات',
        location: 'شارع المحطة',
        distance: '0.5',
        categoryLabel: 'مطعم',
        categoryEmoji: '🍔',
        badgeBgColor: AppColors.warningLight,
        badgeTextColor: AppColors.warning,
        latitude: baseLat + 0.0035,
        longitude: baseLng + 0.0025,
      ),
      SuggestionItemModel(
        title: 'المهندس محمد ناصر للتكييف والتبريد',
        subtitle: 'تبريد وتكييف',
        location: 'القومية',
        distance: '1.4',
        categoryLabel: 'صيانة',
        categoryEmoji: '🔧',
        badgeBgColor: AppColors.primaryLight,
        badgeTextColor: AppColors.primary,
        latitude: baseLat - 0.0090,
        longitude: baseLng + 0.0080,
      ),
      SuggestionItemModel(
        title: 'دكتور أحمد حسن',
        subtitle: 'استشاري امراض باطنة وسكر',
        location: 'شارع فاروق',
        distance: '3.2',
        categoryLabel: 'عيادة',
        categoryEmoji: '🏥',
        badgeBgColor: const Color(0xFFEFF6FF),
        badgeTextColor: const Color(0xFF3B82F6),
        badgeBorderColor: const Color(0xFFBFDBFE),
        latitude: baseLat + 0.0220,
        longitude: baseLng - 0.0180,
      ),
      SuggestionItemModel(
        title: 'شقة غرفتين_القومية',
        subtitle: '',
        price: '8,000',
        location: 'القومية',
        distance: '4.6',
        categoryLabel: 'ايجارات',
        categoryEmoji: '🏠',
        badgeBgColor: AppColors.successLight,
        badgeTextColor: AppColors.success,
        latitude: baseLat - 0.0310,
        longitude: baseLng - 0.0250,
      ),
    ];
  }
}