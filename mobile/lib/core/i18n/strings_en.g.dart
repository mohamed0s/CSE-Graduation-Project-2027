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
	late final Translations$otp$en otp = Translations$otp$en._(_root);
	late final Translations$forgot_password$en forgot_password = Translations$forgot_password$en._(_root);
	late final Translations$reset_password$en reset_password = Translations$reset_password$en._(_root);
	late final Translations$password_changed$en password_changed = Translations$password_changed$en._(_root);
	late final Translations$nav$en nav = Translations$nav$en._(_root);
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

// Path: otp
class Translations$otp$en {
	Translations$otp$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Quick Security Step'
	String get app_bar_title => 'Quick Security Step';

	/// en: 'Let's verify your phone number'
	String get phone_title => 'Let\'s verify your phone number';

	/// en: 'Enter the 6-digit code we sent to your registered phone number'
	String get phone_subtitle => 'Enter the 6-digit code we sent to your registered phone number';

	/// en: 'Let's verify your account'
	String get email_title => 'Let\'s verify your account';

	/// en: 'Enter the 6-digit code we sent to your email address'
	String get email_subtitle => 'Enter the 6-digit code we sent to your email address';

	/// en: 'Verify'
	String get submit_button => 'Verify';

	/// en: 'Didn't receive the code?'
	String get didnt_receive_code => 'Didn\'t receive the code?';

	/// en: 'Resend'
	String get resend => 'Resend';
}

// Path: forgot_password
class Translations$forgot_password$en {
	Translations$forgot_password$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Forgot Password'
	String get app_bar_title => 'Forgot Password';

	/// en: 'Forgot Password?'
	String get title => 'Forgot Password?';

	/// en: 'Enter your details so we can help you recover your account'
	String get subtitle => 'Enter your details so we can help you recover your account';

	/// en: 'Email'
	String get email_label => 'Email';

	/// en: 'Name@Gmail.Com'
	String get email_hint => 'Name@Gmail.Com';

	/// en: 'Send Code'
	String get send_code_button => 'Send Code';

	/// en: 'Remembered your password?'
	String get remembered_password => 'Remembered your password?';

	/// en: 'Log In'
	String get login => 'Log In';

	/// en: 'Need help? Our support team is available for account recovery.'
	String get need_help => 'Need help? Our support team is available for account recovery.';
}

// Path: reset_password
class Translations$reset_password$en {
	Translations$reset_password$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reset Password'
	String get app_bar_title => 'Reset Password';

	/// en: 'Create a New Password'
	String get title => 'Create a New Password';

	/// en: 'Choose a new password so you can access your account safely'
	String get subtitle => 'Choose a new password so you can access your account safely';

	/// en: 'New Password'
	String get new_password_label => 'New Password';

	/// en: 'Confirm Password'
	String get confirm_password_label => 'Confirm Password';

	/// en: 'Change Password'
	String get change_password_button => 'Change Password';

	/// en: 'Remembered your password?'
	String get remembered_password => 'Remembered your password?';

	/// en: 'Log In'
	String get login => 'Log In';
}

// Path: password_changed
class Translations$password_changed$en {
	Translations$password_changed$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Password Changed Successfully! 🎉'
	String get title => 'Password Changed Successfully! 🎉';

	/// en: 'You can now log in using your new password'
	String get subtitle => 'You can now log in using your new password';

	/// en: 'Back to Login'
	String get back_to_login => 'Back to Login';
}

// Path: nav
class Translations$nav$en {
	Translations$nav$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'Services'
	String get services => 'Services';

	/// en: 'Finda Ai'
	String get finda_ai => 'Finda Ai';

	/// en: 'Orders'
	String get orders => 'Orders';

	/// en: 'Ahmed'
	String get profile => 'Ahmed';
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
			'otp.app_bar_title' => 'Quick Security Step',
			'otp.phone_title' => 'Let\'s verify your phone number',
			'otp.phone_subtitle' => 'Enter the 6-digit code we sent to your registered phone number',
			'otp.email_title' => 'Let\'s verify your account',
			'otp.email_subtitle' => 'Enter the 6-digit code we sent to your email address',
			'otp.submit_button' => 'Verify',
			'otp.didnt_receive_code' => 'Didn\'t receive the code?',
			'otp.resend' => 'Resend',
			'forgot_password.app_bar_title' => 'Forgot Password',
			'forgot_password.title' => 'Forgot Password?',
			'forgot_password.subtitle' => 'Enter your details so we can help you recover your account',
			'forgot_password.email_label' => 'Email',
			'forgot_password.email_hint' => 'Name@Gmail.Com',
			'forgot_password.send_code_button' => 'Send Code',
			'forgot_password.remembered_password' => 'Remembered your password?',
			'forgot_password.login' => 'Log In',
			'forgot_password.need_help' => 'Need help? Our support team is available for account recovery.',
			'reset_password.app_bar_title' => 'Reset Password',
			'reset_password.title' => 'Create a New Password',
			'reset_password.subtitle' => 'Choose a new password so you can access your account safely',
			'reset_password.new_password_label' => 'New Password',
			'reset_password.confirm_password_label' => 'Confirm Password',
			'reset_password.change_password_button' => 'Change Password',
			'reset_password.remembered_password' => 'Remembered your password?',
			'reset_password.login' => 'Log In',
			'password_changed.title' => 'Password Changed Successfully! 🎉',
			'password_changed.subtitle' => 'You can now log in using your new password',
			'password_changed.back_to_login' => 'Back to Login',
			'nav.home' => 'Home',
			'nav.services' => 'Services',
			'nav.finda_ai' => 'Finda Ai',
			'nav.orders' => 'Orders',
			'nav.profile' => 'Ahmed',
			_ => null,
		};
	}
}
