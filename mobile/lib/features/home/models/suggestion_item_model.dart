import 'package:flutter/material.dart';

class SuggestionItemModel {
  final String title;
  final String subtitle;
  final String location;
  final String distance;
  final String categoryLabel;
  final String categoryEmoji;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final Color? badgeBorderColor;
  final String? price; 

  const SuggestionItemModel({
    required this.title,
    required this.subtitle,
    required this.location,
    required this.distance,
    required this.categoryLabel,
    required this.categoryEmoji,
    required this.badgeBgColor,
    required this.badgeTextColor,
    this.badgeBorderColor,
    this.price,
  });
}