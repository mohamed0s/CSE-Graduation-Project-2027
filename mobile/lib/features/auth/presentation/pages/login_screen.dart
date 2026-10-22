import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/background/background_blur_glow.dart';
import 'package:mobile/core/widgets/inputs/custom_text_form_field.dart';
import 'package:mobile/generated/style_atoms.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: 32.58.h),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.r),
                    topRight: Radius.circular(40.r),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.r),
                    topRight: Radius.circular(40.r),
                  ),
                  child: Stack(
                    children: [
                      const CustomBackgroundGlow(top: 0, right: 0),
                      Positioned.fill(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            vertical: 34.h,
                            horizontal: 24.w,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.login.title, style: context.bold36Black),
                                SizedBox(height: 8.h),
                                Text(
                                  t.login.subtitle,
                                  style: context.regular16Secondary,
                                ),
                                SizedBox(height: 40.h),
                                CustomTextFormField(
                                  labelStyle: context.bold14Black,
                                  controller: _phoneNumberController,
                                  prefixIcon: Row(
                                    children: [
                                      SizedBox(width: 16.w),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.secondary,
                                      ),
                                      SizedBox(width: 4.w),
                                      Icon(
                                        Icons.flag,
                                        color: AppColors.secondary,
                                      ),
                                    ],
                                  ),
                                  label: t.login.phone_label,
                                  hintText: '123456789',
                                ),
                                SizedBox(height: 16.h),
                                CustomTextFormField(
                                  labelStyle: context.bold14Black,
                                  controller: _passwordController,
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF8A9AAB),
                                  ),
                                  isPassword: true,
                                  label: t.login.password_label,
                                  hintText: '********',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
