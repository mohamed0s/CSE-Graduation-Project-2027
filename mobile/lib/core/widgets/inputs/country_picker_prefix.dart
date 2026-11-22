import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/utils/extensions.dart';

class CountryPickerPrefix extends StatelessWidget {
  final ValueChanged<String> onCodeChanged;
  final String initialSelection;

  const CountryPickerPrefix({
    super.key,
    required this.onCodeChanged,
    this.initialSelection = 'EG',
  });

  @override
  Widget build(BuildContext context) {
    return CountryCodePicker(
      onChanged: (country) {
        if (country.dialCode != null) {
          onCodeChanged(country.dialCode!);
        }
      },
      initialSelection: initialSelection,
      favorite: const ['+20', 'EG', '+966', 'SA'],
      showDropDownButton: false,
      builder: (country) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 14.w),
            if (country?.flagUri != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(2.r),
                child: Image.asset(
                  country!.flagUri!,
                  package: 'country_code_picker',
                  width: 24.w,
                  height: 16.h,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(width: 6.w),
            Text(
              country?.dialCode ?? '+20',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: context.colorScheme.secondary,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Container(
              height: 20.h,
              width: 1.w,
              color: context.colorScheme.outlineVariant,
            ),
            SizedBox(width: 10.w),
          ],
        );
      },
    );
  }
}
