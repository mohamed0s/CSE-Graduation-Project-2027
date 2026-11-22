import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/generated/style_atoms.dart';

class CustomAppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const CustomAppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? context.colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: backgroundColor == null
                  ? Colors.transparent
                  : context.colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: textStyle ??
              context.bold18.copyWith(color: context.colorScheme.onPrimary),
        ),
      ),
    );
  }
}
