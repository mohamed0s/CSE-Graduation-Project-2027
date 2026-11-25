import 'package:flutter/material.dart';
import 'package:mobile/core/i18n/strings.g.dart';

class CategoryModel {
  final String id;
  final String title;
  final String subtitle;
  final String badgeText;
  final IconData icon;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.icon,
  });

  static List<CategoryModel> getCategories(
    BuildContext context, {
    required String city,
  }) {
    final tHome = context.t.home;
    final tServices = context.t.services;

    return [
      CategoryModel(
        id: 'food',
        title: tHome.restaurants_food,
        subtitle: tServices.food_sub,
        badgeText: tServices.food_badge,
        icon: Icons.restaurant_rounded,
      ),
      CategoryModel(
        id: 'health',
        title: tHome.Health_clinics,
        subtitle: tServices.health_sub,
        badgeText: tServices.health_badge,
        icon: Icons.medical_services_outlined,
      ),
      CategoryModel(
        id: 'rentals',
        title: tHome.Property_rentals,
        subtitle: tServices.rentals_sub,
        badgeText: tServices.rentals_badge,
        icon: Icons.real_estate_agent_outlined,
      ),
      CategoryModel(
        id: 'repairs',
        title: tHome.maintenance_services,
        subtitle: tServices.repairs_sub,
        badgeText: tServices.repairs_badge,
        icon: Icons.work_outline_rounded,
      ),
      CategoryModel(
        id: 'banks',
        title: tHome.Banks_ATMs,
        subtitle: tServices.banks_sub,
        badgeText: tServices.banks_badge,
        icon: Icons.account_balance_outlined,
      ),
      CategoryModel(
        id: 'supermarket',
        title: tHome.Supermarkets,
        subtitle: tServices.supermarket_sub,
        badgeText: tServices.supermarket_badge,
        icon: Icons.shopping_cart_outlined,
      ),
      CategoryModel(
        id: 'gov',
        title: tHome.Public_services,
        subtitle: tServices.gov_sub,
        badgeText: tServices.gov_badge,
        icon: Icons.account_balance_wallet_outlined,
      ),
      CategoryModel(
        id: 'shops',
        title: tHome.Shops,
        subtitle: tServices.shops_sub(city: city),
        badgeText: tServices.shops_badge,
        icon: Icons.shopping_bag_outlined,
      ),
      CategoryModel(
        id: 'education',
        title: tHome.Education,
        subtitle: tServices.edu_sub,
        badgeText: tServices.edu_badge,
        icon: Icons.school_outlined,
      ),
      CategoryModel(
        id: 'worship',
        title: tHome.Places_of_worship,
        subtitle: tServices.worship_sub,
        badgeText: tServices.worship_badge,
        icon: Icons.mosque_outlined,
      ),
    ];
  }
}