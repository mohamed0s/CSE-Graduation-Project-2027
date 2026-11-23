import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/routes/app_router.dart';
import 'package:mobile/core/theme/cubit/theme_cubit.dart';
import 'package:mobile/core/utils/extensions.dart';
import 'package:mobile/core/utils/validators.dart';
import 'package:mobile/core/widgets/background/background_blur_glow.dart';
import 'package:mobile/core/widgets/buttons/custom_button.dart';
import 'package:mobile/core/widgets/inputs/country_picker_prefix.dart';
import 'package:mobile/core/widgets/inputs/custom_text_form_field.dart';
import 'package:mobile/features/auth/presentation/widgets/custom_divider_with_text.dart';
import 'package:mobile/features/auth/presentation/widgets/custom_rich_text_widget.dart';
import 'package:mobile/features/auth/presentation/widgets/social_auth_buttons.dart';
import 'package:mobile/generated/style_atoms.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String dialCode = '+20';
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 32.58.h),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerLow,
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
                          CustomBackgroundGlow.topRight(
                            size: 320,
                            preset: GlowPreset.medium,
                          ),
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
                                      t.login.title,
                                      style: context.bold36.copyWith(
                                        color: context.colorScheme.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      t.login.subtitle,
                                      style: context.regular16.copyWith(
                                        color: context
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                    SizedBox(height: 40.h),
                                    CustomTextFormField(
                                      label: t.login.phone_label,
                                      labelStyle: context.bold14.copyWith(
                                        color: context.colorScheme.onSurface,
                                      ),
                                      controller: _phoneNumberController,
                                      keyboardType: TextInputType.phone,
                                      hintText: 'EX: EGY => 1012345678',
                                      prefixIcon: CountryPickerPrefix(
                                        onCodeChanged: (code) {
                                          dialCode = code;
                                        },
                                      ),
                                      validator: Validators.phone,
                                    ),
                                    SizedBox(height: 16.h),
                                    CustomTextFormField(
                                      labelStyle: context.bold14.copyWith(
                                        color: context.colorScheme.onSurface,
                                      ),
                                      controller: _passwordController,
                                      prefixIcon: Icon(
                                        Icons.lock_outline_rounded,
                                        color: context
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      isPassword: true,
                                      label: t.login.password_label,
                                      hintText: '********',
                                    ),
                                    SizedBox(height: 16.h),
                                    Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Text(
                                        t.login.forgot_password,
                                        style: context.bold14.copyWith(
                                          color: context.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 40.h),
                                    CustomAppButton(
                                      text: t.login.login_button,
                                      onPressed: () {},
                                    ),
                                    SizedBox(height: 40.h),
                                    CustomDividerWithText(
                                      text: t.login.or_login_with,
                                    ),
                                    SizedBox(height: 40.h),
                                    SocialAuthButtons(
                                      onGoogleTap: () {},
                                      onAppleTap: () {},
                                    ),
                                    SizedBox(height: 40.h),
                                    CustomRichTextButton(
                                      firstText: t.login.no_account,
                                      secondText: t.login.create_now,
                                      onTap: () {
                                        GoRouter.of(
                                          context,
                                        ).push(AppRouter.signup);
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
            //! TODO: Remove test theme toggle
            PositionedDirectional(
              top: 4.h,
              end: 16.w,
              child: IconButton(
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: context.colorScheme.onSurface,
                ),
                tooltip: 'Toggle Theme',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
