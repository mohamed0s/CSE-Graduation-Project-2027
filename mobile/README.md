# Mobile (Flutter)

**Owner:** Flutter team

## Setup (first time only)

```bash
cd mobile
flutter create --org com.yourteam --project-name grad_app .
```

## Suggested layout

```
mobile/
├── lib/
│   ├── main.dart
│   ├── core/        # theme, constants, API client, utils
│   ├── features/    # one folder per feature (auth/, home/, profile/ ...)
│   └── shared/      # reusable widgets
├── test/
├── assets/
└── pubspec.yaml
```

## Run

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```

## Notes

- Talk **only to the backend** (not directly to the AI service or Gemini).
- Backend URL should be configurable, e.g.
  `flutter run --dart-define=API_URL=http://10.0.2.2:5000`
  (`10.0.2.2` = your PC's localhost from the Android emulator).
- Never commit `google-services.json`, keystores, or API keys.
- Endpoints you can use are in [`docs/api/backend.md`](../docs/api/backend.md).
