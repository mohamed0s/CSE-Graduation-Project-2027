# Frontend (Web)

**Owner:** Frontend team
**Current stack:** Flutter Web (may migrate to React/Next.js later)

## Setup (first time only)

```bash
cd frontend
flutter create --platforms web --project-name grad_web .
```

## Suggested layout

Same as [`mobile/`](../mobile/README.md):

```
frontend/
├── lib/
│   ├── main.dart
│   ├── core/
│   ├── features/
│   └── shared/
├── test/
├── web/
└── pubspec.yaml
```

## Run

```bash
flutter pub get
flutter run -d chrome --dart-define=API_URL=http://localhost:5000
flutter build web
```

## Notes

- Talk **only to the backend**, never to the AI service / Gemini directly.
- Why a separate folder from `mobile/`? So the web app can be migrated to another
  framework later without touching the mobile app.
- If you migrate: delete the Flutter files, scaffold the new app here, and update
  the CI workflow (ask DevOps) and `infra/`.
