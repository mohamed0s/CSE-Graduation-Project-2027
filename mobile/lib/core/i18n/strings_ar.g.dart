///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsAr with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsAr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ar,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ar>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsAr _root = this; // ignore: unused_field

	@override 
	TranslationsAr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsAr(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$login$ar login = _Translations$login$ar._(_root);
	@override late final _Translations$signup$ar signup = _Translations$signup$ar._(_root);
}

// Path: login
class _Translations$login$ar implements Translations$login$en {
	_Translations$login$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'اهلا بيك تاني 👋';
	@override String get subtitle => 'سجل دخولك وخليك جاهز تلاقى كل اللى محتاجه بسهولة';
	@override String get phone_label => 'رقم الموبايل';
	@override String get password_label => 'كلمة السر';
	@override String get forgot_password => 'نسيت كلمة السر؟';
	@override String get login_button => 'تسجيل الدخول';
	@override String get or_login_with => 'أو سجل باستخدام';
	@override String get no_account => 'لسه معندكش حساب؟';
	@override String get create_now => 'اعمل واحد دلوقتي';
}

// Path: signup
class _Translations$signup$ar implements Translations$signup$en {
	_Translations$signup$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'أهلاً بيك 👋';
	@override String get subtitle => 'اعمل حسابك في ثواني وخلينا نسهل عليك كل مرة تحتاج فيها حاجة';
	@override String get name_label => 'الاسم';
	@override String get name_hint => 'احمد محمود';
	@override String get phone_label => 'رقم الموبايل';
	@override String get email_label => 'البريد الإلكتروني';
	@override String get email_hint => 'Name@Gmail.Com';
	@override String get password_label => 'كلمة السر';
	@override String get confirm_password_label => 'تأكيد كلمة السر';
	@override String get signup_button => 'إنشاء حساب';
	@override String get or_signup_with => 'أو سجل الدخول عبر';
	@override String get have_account => 'عندك حساب؟';
	@override String get login_now => 'سجل الدخول دلوقتي';
}

/// The flat map containing all translations for locale <ar>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsAr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'login.title' => 'اهلا بيك تاني 👋',
			'login.subtitle' => 'سجل دخولك وخليك جاهز تلاقى كل اللى محتاجه بسهولة',
			'login.phone_label' => 'رقم الموبايل',
			'login.password_label' => 'كلمة السر',
			'login.forgot_password' => 'نسيت كلمة السر؟',
			'login.login_button' => 'تسجيل الدخول',
			'login.or_login_with' => 'أو سجل باستخدام',
			'login.no_account' => 'لسه معندكش حساب؟',
			'login.create_now' => 'اعمل واحد دلوقتي',
			'signup.title' => 'أهلاً بيك 👋',
			'signup.subtitle' => 'اعمل حسابك في ثواني وخلينا نسهل عليك كل مرة تحتاج فيها حاجة',
			'signup.name_label' => 'الاسم',
			'signup.name_hint' => 'احمد محمود',
			'signup.phone_label' => 'رقم الموبايل',
			'signup.email_label' => 'البريد الإلكتروني',
			'signup.email_hint' => 'Name@Gmail.Com',
			'signup.password_label' => 'كلمة السر',
			'signup.confirm_password_label' => 'تأكيد كلمة السر',
			'signup.signup_button' => 'إنشاء حساب',
			'signup.or_signup_with' => 'أو سجل الدخول عبر',
			'signup.have_account' => 'عندك حساب؟',
			'signup.login_now' => 'سجل الدخول دلوقتي',
			_ => null,
		};
	}
}
