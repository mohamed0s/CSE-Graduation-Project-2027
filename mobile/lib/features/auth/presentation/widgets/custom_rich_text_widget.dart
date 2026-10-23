import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/generated/style_atoms.dart';

class CustomRichTextButton extends StatelessWidget {
  final String firstText;
  final String secondText;
  final VoidCallback onTap;

  const CustomRichTextButton({
    super.key,
    required this.firstText,
    required this.secondText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: '$firstText ',
          style: context.regular16Secondary,
          children: [
            TextSpan(
              text: secondText,
              style: context.regular16Primary.copyWith(
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}
