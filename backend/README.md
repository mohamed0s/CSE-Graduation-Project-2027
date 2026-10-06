# Backend (.NET Web API)

**Owner:** Backend team

## Setup (first time only)

```bash
cd backend
dotnet new sln -n Backend
dotnet new webapi -n Backend.Api -o src/Backend.Api
dotnet new xunit  -n Backend.Tests -o tests/Backend.Tests
dotnet sln add src/Backend.Api tests/Backend.Tests
dotnet add tests/Backend.Tests reference src/Backend.Api
```

## Suggested layout

```
backend/
├── src/Backend.Api/     # Controllers, services, data access, migrations
├── tests/Backend.Tests/ # Unit / integration tests
├── Dockerfile
└── Backend.sln
```

## Run

```bash
dotnet run --project src/Backend.Api
dotnet test
```

## Notes

- Expose the API on port **8080** inside Docker (DevOps maps it to `5000` locally).
- Connection string comes from env var `ConnectionStrings__Default` – never hardcode it.
- Local secrets go in `appsettings.Development.json` (git-ignored) or `dotnet user-secrets`.
- Calls to the AI service go through `AI_SERVICE_URL` (e.g. `http://ai:8000`).
- Keep [`docs/api/backend.md`](../docs/api/backend.md) up to date when you add/change endpoints.
- Add a `GET /health` endpoint – DevOps uses it.
