// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mobile/core/theme/app_colors.dart';
// import 'package:mobile/core/i18n/strings.g.dart';
// import 'package:mobile/generated/style_atoms.dart';

// class LocationPickerBottomSheet extends StatefulWidget {
//   final Function(String country, String state, String city) onLocationConfirmed;

//   const LocationPickerBottomSheet({
//     super.key,
//     required this.onLocationConfirmed,
//   });

//   @override
//   State<LocationPickerBottomSheet> createState() =>
//       _LocationPickerBottomSheetState();
// }

// class _LocationPickerBottomSheetState extends State<LocationPickerBottomSheet> {
//   String _countryValue = '';
//   String _stateValue = '';
//   String _cityValue = '';

//   @override
//   Widget build(BuildContext context) {
//     final t = context.t.location;
    

//     return Container(
//       padding: EdgeInsets.only(
//         left: 20.w,
//         right: 20.w,
//         top: 16.h,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Center(
//             child: Container(
//               width: 40.w,
//               height: 4.h,
//               decoration: BoxDecoration(
//                 color: AppColors.borderLight,
//                 borderRadius: BorderRadius.circular(4.r),
//               ),
//             ),
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             t.choose_country_city,
//             textAlign: TextAlign.center,
//             style: context.bold16TextMain,
//           ),
//           SizedBox(height: 20.h),

//           // باكدج csc_picker_plus
//           CSCPickerPlus(
//             layout: Layout.vertical,
//             flagState: CountryFlag.ENABLE,
           
//             defaultCountry: CscCountry.Egypt,
//             dropdownDecoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12.r),
//               color: AppColors.backgroundLight,
//               border: Border.all(color: AppColors.borderLight),
//             ),
//             disabledDropdownDecoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12.r),
//               color: AppColors.buttonDisabled.withOpacity(0.5),
//               border: Border.all(color: AppColors.borderLight),
//             ),
//             selectedItemStyle: context.medium14TextMain,
//             dropdownHeadingStyle: context.bold16TextMain,
//             dropdownItemStyle: context.regular14TextMain,
//             onCountryChanged: (value) {
//               setState(() => _countryValue = value);
//             },
//             onStateChanged: (value) {
//               setState(() => _stateValue = value ?? '');
//             },
//             onCityChanged: (value) {
//               setState(() => _cityValue = value ?? '');
//             },
//           ),
//           SizedBox(height: 24.h),

//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               padding: EdgeInsets.symmetric(vertical: 14.h),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14.r),
//               ),
//             ),
//             onPressed: (_cityValue.isEmpty && _stateValue.isEmpty)
//                 ? null
//                 : () {
//                     // تنظيف اسم الدولة من علم الإيموجي إن وُجد
//                     final cleanCountry =
//                         _countryValue.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '').trim();
//                     final chosenCity =
//                         _cityValue.isNotEmpty ? _cityValue : _stateValue;

//                     widget.onLocationConfirmed(
//                       cleanCountry,
//                       _stateValue,
//                       chosenCity,
//                     );
//                     Navigator.pop(context);
//                   },
//             child: Text(t.confirm_location, style: context.bold14White),
//           ),
//         ],
//       ),
//     );
//   }
// }