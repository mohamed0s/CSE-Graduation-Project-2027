///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$login$en login = Translations$login$en._(_root);
	late final Translations$signup$en signup = Translations$signup$en._(_root);
}

// Path: login
class Translations$login$en {
	Translations$login$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome back 👋'
	String get title => 'Welcome back 👋';

	/// en: 'Log in and get ready to find everything you need easily'
	String get subtitle => 'Log in and get ready to find everything you need easily';

	/// en: 'Phone Number'
	String get phone_label => 'Phone Number';

	/// en: 'Password'
	String get password_label => 'Password';

	/// en: 'Forgot Password?'
	String get forgot_password => 'Forgot Password?';

	/// en: 'Log In'
	String get login_button => 'Log In';

	/// en: 'Or log in with'
	String get or_login_with => 'Or log in with';

	/// en: 'Don't have an account yet?'
	String get no_account => 'Don\'t have an account yet?';

	/// en: 'Create one now'
	String get create_now => 'Create one now';
}

// Path: signup
class Translations$signup$en {
	Translations$signup$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome 👋'
	String get title => 'Welcome 👋';

	/// en: 'Create your account in seconds and let us make it easier for you every time you need something'
	String get subtitle => 'Create your account in seconds and let us make it easier for you every time you need something';

	/// en: 'Name'
	String get name_label => 'Name';

	/// en: 'Ahmed Mahmoud'
	String get name_hint => 'Ahmed Mahmoud';

	/// en: 'Phone Number'
	String get phone_label => 'Phone Number';

	/// en: 'Email'
	String get email_label => 'Email';

	/// en: 'Name@Gmail.Com'
	String get email_hint => 'Name@Gmail.Com';

	/// en: 'Password'
	String get password_label => 'Password';

	/// en: 'Confirm Password'
	String get confirm_password_label => 'Confirm Password';

	/// en: 'Create Account'
	String get signup_button => 'Create Account';

	/// en: 'Or log in via'
	String get or_signup_with => 'Or log in via';

	/// en: 'Already have an account?'
	String get have_account => 'Already have an account?';

	/// en: 'Log in now'
	String get login_now => 'Log in now';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'login.title' => 'Welcome back 👋',
			'login.subtitle' => 'Log in and get ready to find everything you need easily',
			'login.phone_label' => 'Phone Number',
			'login.password_label' => 'Password',
			'login.forgot_password' => 'Forgot Password?',
			'login.login_button' => 'Log In',
			'login.or_login_with' => 'Or log in with',
			'login.no_account' => 'Don\'t have an account yet?',
			'login.create_now' => 'Create one now',
			'signup.title' => 'Welcome 👋',
			'signup.subtitle' => 'Create your account in seconds and let us make it easier for you every time you need something',
			'signup.name_label' => 'Name',
			'signup.name_hint' => 'Ahmed Mahmoud',
			'signup.phone_label' => 'Phone Number',
			'signup.email_label' => 'Email',
			'signup.email_hint' => 'Name@Gmail.Com',
			'signup.password_label' => 'Password',
			'signup.confirm_password_label' => 'Confirm Password',
			'signup.signup_button' => 'Create Account',
			'signup.or_signup_with' => 'Or log in via',
			'signup.have_account' => 'Already have an account?',
			'signup.login_now' => 'Log in now',
			_ => null,
		};
	}
}
