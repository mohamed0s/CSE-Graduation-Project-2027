//! you can add dark them in the app like this
//! context.read<ThemeCubit>().toggleTheme()

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/cache/cache_helper.dart';
import 'package:mobile/core/utils/constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_initialThemeMode);

  static ThemeMode get _initialThemeMode {
    final savedMode = CacheHelper.instance.getDataString(
      key: AppConstants.themeKey,
    );
    return switch (savedMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    await CacheHelper.instance.saveData(
      key: AppConstants.themeKey,
      value: mode.name,
    );
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
