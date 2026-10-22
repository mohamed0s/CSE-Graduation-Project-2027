import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/app_colors.dart';

class CustomTextFormField extends StatefulWidget {
  final String label;
  final TextStyle? labelStyle;
  final String hintText;
  final Widget? prefixIcon;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const CustomTextFormField({
    super.key,
    required this.label,
    this.labelStyle,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    required this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            widget.label,
            style:
                widget.labelStyle ??
                TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: widget.controller,
          obscureText: _isObscured,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF8A9AAB),
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.primary),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.red),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
