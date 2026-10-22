import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/app.dart';
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

  runApp(TranslationProvider(child: const MyApp()));
}
