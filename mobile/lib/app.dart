import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:mobile/core/routes/app_router.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/theme/cubit/theme_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            final Brightness platformBrightness =
                MediaQuery.platformBrightnessOf(context);
            final bool isDark = themeMode == ThemeMode.dark ||
                (themeMode == ThemeMode.system &&
                    platformBrightness == Brightness.dark);

            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
                statusBarBrightness:
                    isDark ? Brightness.dark : Brightness.light,
              ),
            );

            return MaterialApp.router(
              locale: TranslationProvider.of(context).flutterLocale,
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              routerConfig: AppRouter.router,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
            );
          },
        );
      },
    );
  }
}
