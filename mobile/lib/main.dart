import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app.dart';
import 'package:mobile/core/i18n/controller/locale_cubit.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  LocaleSettings.useDeviceLocale();
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize dependency injection
  await di.init();

  runApp(
    BlocProvider(
      create: (context) => LocaleCubit(),
      child: TranslationProvider(child: const MyApp()),
    ),
  );
}
