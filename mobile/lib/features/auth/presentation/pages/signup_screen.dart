import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/routes/app_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/background/background_blur_glow.dart';
import 'package:mobile/core/widgets/buttons/custom_button.dart';
import 'package:mobile/core/widgets/inputs/country_picker_prefix.dart';
import 'package:mobile/core/widgets/inputs/custom_text_form_field.dart';
import 'package:mobile/features/auth/presentation/widgets/custom_divider_with_text.dart';
import 'package:mobile/features/auth/presentation/widgets/custom_rich_text_widget.dart';
import 'package:mobile/features/auth/presentation/widgets/social_auth_buttons.dart';
import 'package:mobile/generated/style_atoms.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _dialCode = '+20';
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _phoneNumberController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.signup.title,
                                  style: context.bold36Black,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  t.signup.subtitle,
                                  style: context.regular16Secondary,
                                ),
                                SizedBox(height: 40.h),
                                CustomTextFormField(
                                  label: t.signup.name_label,
                                  labelStyle: context.bold14Black,
                                  controller: _nameController,
                                  keyboardType: TextInputType.text,
                                  hintText: t.signup.name_hint,
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                    color: Color(0xFF8A9AAB),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    if (!RegExp(
                                      r'^[a-zA-Z\s]+$',
                                    ).hasMatch(value.trim())) {
                                      return 'Name can only contain letters and spaces';
                                    }
                                    if (value.trim().length < 3) {
                                      return 'Name must be at least 3 characters long';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                                CustomTextFormField(
                                  label: t.login.phone_label,
                                  labelStyle: context.bold14Black,
                                  controller: _phoneNumberController,
                                  keyboardType: TextInputType.phone,
                                  hintText: 'EX: EGY => 1012345678',
                                  prefixIcon: CountryPickerPrefix(
                                    onCodeChanged: (code) {
                                      _dialCode = code;
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    if (_dialCode == '+20' &&
                                        !RegExp(
                                          r'^1[0125][0-9]{8}$',
                                        ).hasMatch(value.trim())) {
                                      return 'Invalid Egyptian phone number';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                                CustomTextFormField(
                                  label: t.signup.email_label,
                                  labelStyle: context.bold14Black,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  hintText: t.signup.email_hint,
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF8A9AAB),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value.trim())) {
                                      return 'Invalid email address';
                                    }
                                    return null;
                                  },
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
                                  label: t.signup.password_label,
                                  hintText: '********',
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters long';
                                    }
                                    if (!RegExp(
                                      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
                                    ).hasMatch(value.trim())) {
                                      return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                                CustomTextFormField(
                                  labelStyle: context.bold14Black,
                                  controller: _confirmPasswordController,
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF8A9AAB),
                                  ),
                                  isPassword: true,
                                  label: t.signup.confirm_password_label,
                                  hintText: '********',
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 40.h),
                                CustomAppButton(
                                  text: t.signup.signup_button,
                                  onPressed: () {},
                                ),
                                SizedBox(height: 40.h),
                                CustomDividerWithText(
                                  text: t.signup.or_signup_with,
                                ),
                                SizedBox(height: 40.h),
                                SocialAuthButtons(
                                  onGoogleTap: () {},
                                  onAppleTap: () {},
                                ),
                                SizedBox(height: 40.h),
                                CustomRichTextButton(
                                  firstText: t.signup.have_account,
                                  secondText: t.signup.login_now,
                                  onTap: () {
                                    GoRouter.of(context).push(AppRouter.login);
                                  },
                                ),
                                SizedBox(height: 40.h),
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
