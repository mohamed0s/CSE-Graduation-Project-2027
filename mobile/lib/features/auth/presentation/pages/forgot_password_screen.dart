// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/routes/app_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/validators.dart';
import 'package:mobile/core/widgets/background/background_blur_glow.dart';
import 'package:mobile/core/widgets/buttons/custom_button.dart';
import 'package:mobile/core/widgets/inputs/custom_text_form_field.dart';
import 'package:mobile/features/auth/presentation/widgets/auth_header_icon.dart';
import 'package:mobile/features/auth/presentation/widgets/auth_support_banner.dart';
import 'package:mobile/features/auth/presentation/widgets/custom_rich_text_widget.dart';
import 'package:mobile/generated/style_atoms.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(t.forgot_password.app_bar_title),
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textSub,
        titleTextStyle: context.bold18TextSub,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textSub, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  CustomBackgroundGlow(top: -20, left: -10),
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: 37.h,
                        right: 24.w,
                        left: 24.w,
                        bottom: 84.h,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 8.h),
                            AuthHeaderIcon(
                              size: 62,
                              iconSize: 30,
                              icon: Icons.lock_reset_rounded,
                            ),
                            SizedBox(height: 48.h),
                            Text(
                              t.forgot_password.title,
                              style: context.bold36Black,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              t.forgot_password.subtitle,
                              style: context.regular18Secondary,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 48.h),
                            SizedBox(
                              height: 250.h,
                              width: 284.w,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 16.r,
                                      spreadRadius: 2.r,
                                      //offset: const Offset(0, -4),
                                    ),
                                  ],
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(40.r),
                                ),

                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40.r),
                                  child: Stack(
                                    children: [
                                      const CustomBackgroundGlow(
                                        top: -40,
                                        right: -40,
                                      ),
                                      Positioned.fill(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 34.h,
                                            horizontal: 24.w,
                                          ),
                                          child: Column(
                                            children: [
                                              CustomTextFormField(
                                                prefixIcon: const Icon(
                                                  Icons.email_outlined,
                                                  color: Color(0xFF8A9AAB),
                                                ),

                                                controller: _emailController,
                                                label: t
                                                    .forgot_password
                                                    .email_label,
                                                hintText: t
                                                    .forgot_password
                                                    .email_hint,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                validator: Validators.email,
                                              ),
                                              SizedBox(height: 32.h),
                                              CustomAppButton(
                                                text: t
                                                    .forgot_password
                                                    .send_code_button,
                                                onPressed: () {
                                                  GoRouter.of(context).push(
                                                    AppRouter.resetPassword,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 28.h),
                            CustomRichTextButton(
                              firstText: t.forgot_password.remembered_password,
                              secondText: t.forgot_password.login,
                              onTap: () {},
                            ),
                            SizedBox(height: 24.h),
                            AuthSupportBanner(onTap: () {}),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
