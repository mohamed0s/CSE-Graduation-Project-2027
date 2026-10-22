import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/i18n/strings.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<AppLocale> {
  static const String _languageKey = 'user_language';

  LocaleCubit() : super(AppLocale.en) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(_languageKey);

    if (savedLanguageCode != null) {
      final locale = AppLocaleUtils.parse(savedLanguageCode);
      LocaleSettings.setLocale(locale);
      emit(locale);
    } else {
      final deviceLocale = LocaleSettings.useDeviceLocale();
      emit(await deviceLocale);
    }
  }

  Future<void> changeLanguage(AppLocale newLocale) async {
    if (state == newLocale) return;

    LocaleSettings.setLocale(newLocale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, newLocale.languageCode);

    emit(newLocale);
  }
}

/*
 * 🌐 LocaleCubit - Language State Management
 *
 * How to use this Cubit in the UI (e.g., Settings Screen):
 * 
 * 1. To change language to Arabic on button click:
 *    context.read<LocaleCubit>().changeLanguage(AppLocale.ar);
 * 
 * 2. To change language to English on button click:
 *    context.read<LocaleCubit>().changeLanguage(AppLocale.en);
 * 
 * 3. To update a specific UI element based on current language (like a checkmark):
 *    BlocBuilder<LocaleCubit, AppLocale>(
 *      builder: (context, currentLocale) {
 *        bool isArabic = currentLocale == AppLocale.ar;
 *        return Text(isArabic ? 'العربية' : 'English');
 *      },
 *    )
 * 
 * Note: The whole app rebuilds automatically when language changes 
 * because of `TranslationProvider` in main.dart.
 */
