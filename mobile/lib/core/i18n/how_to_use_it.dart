// # 🌐 Localization Guidelines (slang)

// ## 1. How to add new translations:
// - Add key-value pairs to both `lib/core/i18n/en.i18n.json` and `lib/core/i18n/ar.i18n.json`.
// - Keep the keys identical in both files.

// Example JSON:
// {
//   "auth": {
//     "login": "Login",
//     "welcome": "Welcome back, {name}" // with arguments
//   }
// }

// ## 2. Generate translation code:
// After updating JSON files, run this command in your terminal:
// $ dart run slang

// ## 3. How to use in UI:

// Usage:
// Text(t.auth.login);
// Text(t.auth.welcome(name: 'User')); // passing variables

// ## 4. Switching Language:
// LocaleSettings.setLocale(AppLocale.ar); // Switch to Arabic
// LocaleSettings.setLocale(AppLocale.en); // Switch to English
