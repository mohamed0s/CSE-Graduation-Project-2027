import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/features/home/models/suggestion_item_model.dart';
import 'package:mobile/features/home/widgets/suggestion_card.dart';
import 'package:mobile/generated/style_atoms.dart';

class SuggestionsListSection extends StatelessWidget {
  final String title;
  final List<SuggestionItemModel> suggestions;

  const SuggestionsListSection({
    super.key,
    required this.title,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Text('📍', style: TextStyle(fontSize: 16.sp)),
              SizedBox(width: 6.w),
              Text(
                title,
                style: context.bold14.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestions.length,
          itemBuilder: (context, index) =>
              SuggestionCard(item: suggestions[index], onTap: () {}),
        ),
      ],
    );
  }
}