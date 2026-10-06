# Backend API

Base URL (local): `http://localhost:5000`

> Backend team: add every endpoint here. Mobile/Web teams build against this.
> Tip: Swagger is also available at `/swagger` when running locally.

## Health

`GET /health` → `200 OK`

## Example (delete when you add real ones)

### `POST /api/auth/login`

Request:
```json
{ "email": "user@example.com", "password": "secret" }
```

Response `200`:
```json
{ "token": "eyJhbGciOi...", "user": { "id": 1, "name": "Ahmed" } }
```

Errors: `401` wrong credentials.
