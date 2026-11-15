import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/auth/presentation/widgets/auth_header_icon.dart';
import 'package:mobile/features/auth/presentation/widgets/custom_otp_field.dart';
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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(t.otp.app_bar_title),
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
            SizedBox(height: 32.58.h),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: 24.h,
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
                            style: context.bold36Black,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            t.otp.phone_subtitle,
                            style: context.regular18Secondary,
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
                                onCompleted: (pin) {
                                  _verifyCode();
                                },
                              ),
                            ),
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
