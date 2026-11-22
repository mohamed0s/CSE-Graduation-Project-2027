import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/generated/style_atoms.dart';

class CustomDividerWithText extends StatelessWidget {
  final String text;

  const CustomDividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: context.colorScheme.outlineVariant,
            thickness: 1.5,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            text,
            style: context.semiBold14.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: context.colorScheme.outlineVariant,
            thickness: 1.5,
          ),
        ),
      ],
    );
  }
}
