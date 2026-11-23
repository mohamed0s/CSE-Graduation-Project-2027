// ignore_for_file: unused_element, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/routes/app_router.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/core/widgets/background/background_blur_glow.dart';
import 'package:mobile/core/widgets/buttons/custom_button.dart';
import 'package:mobile/features/auth/presentation/widgets/auth_header_icon.dart';
import 'package:mobile/features/auth/presentation/widgets/custom_otp_field.dart';
import 'package:mobile/features/auth/presentation/widgets/custom_rich_text_widget.dart';
import 'package:mobile/generated/style_atoms.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _verifyCode() {
    if (_formKey.currentState!.validate()) {
      final otpCode = _otpController.text;
      // context.read<AuthCubit>().verifyOtp(code: otpCode, ...);
    }
  }

  bool isRtl() {
    return Directionality.of(context) == TextDirection.rtl;
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(t.otp.app_bar_title),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: context.colorScheme.onSurface,
        titleTextStyle: context.bold18.copyWith(
          color: context.colorScheme.onSurface,
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: context.colorScheme.onSurface,
            size: 20,
          ),
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
                  CustomBackgroundGlow(top: -20, right: -10),
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: 37.h,
                        right: 24.w,
                        left: 24.w,
                        bottom: 84.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 8.h),
                          AuthHeaderIcon(
                            size: 96,
                            iconSize: 50,
                            icon: Icons.lock_reset_rounded,
                          ),
                          SizedBox(height: 48.h),
                          Text(
                            t.otp.phone_title,
                            style: context.bold36.copyWith(
                              color: context.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            t.otp.phone_subtitle,
                            style: context.regular18.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 48.h),
                          Directionality(
                            textDirection: isRtl()
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            child: Form(
                              key: _formKey,
                              child: CustomOtpField(
                                controller: _otpController,
                                validator: (value) {
                                  if (value == null || value.length < 6) {
                                    return 'Please enter the 6-digit code';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 56.h),
                          CustomAppButton(
                            text: t.otp.submit_button,
                            onPressed: () {
                              context.push(AppRouter.forgotPassword);
                            },
                          ),
                          SizedBox(height: 48.h),
                          CustomRichTextButton(
                            firstText: t.otp.didnt_receive_code,
                            secondText: t.otp.resend,
                            onTap: () {},
                          ),
                        ],
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
