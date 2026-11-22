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
	@override late final _Translations$otp$ar otp = _Translations$otp$ar._(_root);
	@override late final _Translations$forgot_password$ar forgot_password = _Translations$forgot_password$ar._(_root);
	@override late final _Translations$reset_password$ar reset_password = _Translations$reset_password$ar._(_root);
	@override late final _Translations$password_changed$ar password_changed = _Translations$password_changed$ar._(_root);
	@override late final _Translations$nav$ar nav = _Translations$nav$ar._(_root);
	@override late final _Translations$home$ar home = _Translations$home$ar._(_root);
	@override late final _Translations$location$ar location = _Translations$location$ar._(_root);
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

// Path: otp
class _Translations$otp$ar implements Translations$otp$en {
	_Translations$otp$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get app_bar_title => 'خطوة أمان بسيطة';
	@override String get phone_title => 'خلينا نتأكد انه رقم تلفونك';
	@override String get phone_subtitle => 'دخل الكود المكون من 6 أرقام اللي بعتناهولك على رقم التلفون اللي سجلت بيه';
	@override String get email_title => 'خلينا نتأكد انه حسابك';
	@override String get email_subtitle => 'دخل الكود المكون من 6 أرقام اللي بعتناهولك على البريد الالكتروني';
	@override String get submit_button => 'ارسال';
	@override String get didnt_receive_code => 'الكود موصلش؟';
	@override String get resend => 'إعادة الإرسال';
}

// Path: forgot_password
class _Translations$forgot_password$ar implements Translations$forgot_password$en {
	_Translations$forgot_password$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get app_bar_title => 'نسيت كلمة السر';
	@override String get title => 'نسيت كلمة السر؟';
	@override String get subtitle => 'دخل بياناتك عشان نساعدك ترجع حسابك';
	@override String get email_label => 'البريد الإلكتروني';
	@override String get email_hint => 'Name@Gmail.Com';
	@override String get send_code_button => 'ابعتلي الكود';
	@override String get remembered_password => 'افتكرت كلمة السر؟';
	@override String get login => 'تسجيل الدخول';
	@override String get need_help => 'هل تحتاج إلى مساعدة؟ فريق الدعم متاح لاستعادة الحساب.';
}

// Path: reset_password
class _Translations$reset_password$ar implements Translations$reset_password$en {
	_Translations$reset_password$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get app_bar_title => 'إعادة تعيين كلمة السر';
	@override String get title => 'اعمل كلمة سر جديدة';
	@override String get subtitle => 'اختار كلمة سر جديدة عشان تقدر تدخل حسابك بأمان';
	@override String get new_password_label => 'كلمة السر الجديدة';
	@override String get confirm_password_label => 'تأكيد كلمة السر';
	@override String get change_password_button => 'تغيير كلمة السر';
	@override String get remembered_password => 'افتكرت كلمة السر؟';
	@override String get login => 'تسجيل الدخول';
}

// Path: password_changed
class _Translations$password_changed$ar implements Translations$password_changed$en {
	_Translations$password_changed$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'كلمة السر اتغيّرت بنجاح! 🎉';
	@override String get subtitle => 'دلوقتي تقدر تسجّل دخولك باستخدام كلمة السر الجديدة';
	@override String get back_to_login => 'ارجع لصفحة تسجيل الدخول';
}

// Path: nav
class _Translations$nav$ar implements Translations$nav$en {
	_Translations$nav$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get home => 'الرئيسية';
	@override String get services => 'الخدمات';
	@override String get finda_ai => 'Finda Ai';
	@override String get orders => 'طلباتي';
	@override String get profile => 'أحمد';
}

// Path: home
class _Translations$home$ar implements Translations$home$en {
	_Translations$home$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get app_name_ar => 'فين ده';
	@override String get app_name_en => 'Finda';
	@override String get discover => 'اكتشف';
	@override String get finda_ai => 'Finda Ai';
	@override String get my_orders => 'طلباتي';
	@override String get craftsmen => 'صنايعية';
	@override String banner_badge({required Object city}) => 'كل خدمات ${city} في مكان واحد';
	@override String get banner_title => 'كل الخدمات والأماكن اللي بتدور عليها في مكان واحد';
	@override String get banner_subtitle => 'من المطاعم والصنايعية للعيادات والإيجارات والبنوك والمصالح الحكومية، فين ده! هيسهّل عليك تلاقي اللي بتدور عليه.';
	@override String get quick_categories => 'الخدمات والتصنيفات السريعة';
	@override String get view_all => 'عرض الكل';
	@override String get all => 'الكل';
	@override String get restaurants_food => 'مطاعم واكل';
	@override String get maintenance_services => 'خدمات وصيانة';
	@override String search_in_city({required Object city}) => 'دور على اللي محتاجه في ${city}';
	@override String get list_view => 'عرض القائمة';
	@override String get map_view => 'الخريطة';
	@override String get search_hint => 'قول ل فين ده انت محتاج ايه؟(مثال: سباك,شقة للايجار,برجر)';
	@override String get use_current_location => 'استخدم موقعى الحالى لتحديد الاقرب';
	@override String get nearby_suggestions => 'مقترحات قريبة منك';
	@override String distance_km({required Object distance}) => '${distance} كم';
	@override String price_per_month({required Object price}) => '${price} ج / شهر';
}

// Path: location
class _Translations$location$ar implements Translations$location$en {
	_Translations$location$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get select_location_hint => 'حدد موقعك';
	@override String get choose_country_city => 'اختر الدولة والمدينة';
	@override String get confirm_location => 'تأكيد الموقع';
	@override String get location_permission_title => 'تفعيل خدمة الموقع';
	@override String get location_permission_desc => 'نحتاج إلى الوصول لموقعك لعرض الخريطة وتحديد موقعك الحالي والخدمات والأماكن القريبة منك بدقة.';
	@override String get enable_location_btn => 'تفعيل الموقع';
	@override String get open_settings_btn => 'فتح الإعدادات';
	@override String get cancel_btn => 'إلغاء';
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
			'otp.app_bar_title' => 'خطوة أمان بسيطة',
			'otp.phone_title' => 'خلينا نتأكد انه رقم تلفونك',
			'otp.phone_subtitle' => 'دخل الكود المكون من 6 أرقام اللي بعتناهولك على رقم التلفون اللي سجلت بيه',
			'otp.email_title' => 'خلينا نتأكد انه حسابك',
			'otp.email_subtitle' => 'دخل الكود المكون من 6 أرقام اللي بعتناهولك على البريد الالكتروني',
			'otp.submit_button' => 'ارسال',
			'otp.didnt_receive_code' => 'الكود موصلش؟',
			'otp.resend' => 'إعادة الإرسال',
			'forgot_password.app_bar_title' => 'نسيت كلمة السر',
			'forgot_password.title' => 'نسيت كلمة السر؟',
			'forgot_password.subtitle' => 'دخل بياناتك عشان نساعدك ترجع حسابك',
			'forgot_password.email_label' => 'البريد الإلكتروني',
			'forgot_password.email_hint' => 'Name@Gmail.Com',
			'forgot_password.send_code_button' => 'ابعتلي الكود',
			'forgot_password.remembered_password' => 'افتكرت كلمة السر؟',
			'forgot_password.login' => 'تسجيل الدخول',
			'forgot_password.need_help' => 'هل تحتاج إلى مساعدة؟ فريق الدعم متاح لاستعادة الحساب.',
			'reset_password.app_bar_title' => 'إعادة تعيين كلمة السر',
			'reset_password.title' => 'اعمل كلمة سر جديدة',
			'reset_password.subtitle' => 'اختار كلمة سر جديدة عشان تقدر تدخل حسابك بأمان',
			'reset_password.new_password_label' => 'كلمة السر الجديدة',
			'reset_password.confirm_password_label' => 'تأكيد كلمة السر',
			'reset_password.change_password_button' => 'تغيير كلمة السر',
			'reset_password.remembered_password' => 'افتكرت كلمة السر؟',
			'reset_password.login' => 'تسجيل الدخول',
			'password_changed.title' => 'كلمة السر اتغيّرت بنجاح! 🎉',
			'password_changed.subtitle' => 'دلوقتي تقدر تسجّل دخولك باستخدام كلمة السر الجديدة',
			'password_changed.back_to_login' => 'ارجع لصفحة تسجيل الدخول',
			'nav.home' => 'الرئيسية',
			'nav.services' => 'الخدمات',
			'nav.finda_ai' => 'Finda Ai',
			'nav.orders' => 'طلباتي',
			'nav.profile' => 'أحمد',
			'home.app_name_ar' => 'فين ده',
			'home.app_name_en' => 'Finda',
			'home.discover' => 'اكتشف',
			'home.finda_ai' => 'Finda Ai',
			'home.my_orders' => 'طلباتي',
			'home.craftsmen' => 'صنايعية',
			'home.banner_badge' => ({required Object city}) => 'كل خدمات ${city} في مكان واحد',
			'home.banner_title' => 'كل الخدمات والأماكن اللي بتدور عليها في مكان واحد',
			'home.banner_subtitle' => 'من المطاعم والصنايعية للعيادات والإيجارات والبنوك والمصالح الحكومية، فين ده! هيسهّل عليك تلاقي اللي بتدور عليه.',
			'home.quick_categories' => 'الخدمات والتصنيفات السريعة',
			'home.view_all' => 'عرض الكل',
			'home.all' => 'الكل',
			'home.restaurants_food' => 'مطاعم واكل',
			'home.maintenance_services' => 'خدمات وصيانة',
			'home.search_in_city' => ({required Object city}) => 'دور على اللي محتاجه في ${city}',
			'home.list_view' => 'عرض القائمة',
			'home.map_view' => 'الخريطة',
			'home.search_hint' => 'قول ل فين ده انت محتاج ايه؟(مثال: سباك,شقة للايجار,برجر)',
			'home.use_current_location' => 'استخدم موقعى الحالى لتحديد الاقرب',
			'home.nearby_suggestions' => 'مقترحات قريبة منك',
			'home.distance_km' => ({required Object distance}) => '${distance} كم',
			'home.price_per_month' => ({required Object price}) => '${price} ج / شهر',
			'location.select_location_hint' => 'حدد موقعك',
			'location.choose_country_city' => 'اختر الدولة والمدينة',
			'location.confirm_location' => 'تأكيد الموقع',
			'location.location_permission_title' => 'تفعيل خدمة الموقع',
			'location.location_permission_desc' => 'نحتاج إلى الوصول لموقعك لعرض الخريطة وتحديد موقعك الحالي والخدمات والأماكن القريبة منك بدقة.',
			'location.enable_location_btn' => 'تفعيل الموقع',
			'location.open_settings_btn' => 'فتح الإعدادات',
			'location.cancel_btn' => 'إلغاء',
			_ => null,
		};
	}
}
