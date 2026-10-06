# AI Service API

Base URL (local): `http://localhost:8000` · inside Docker: `http://ai:8000`
Called by: **backend only**

> AI team: add every endpoint here so the backend team knows how to call you.
> Tip: FastAPI auto-docs are at `/docs` when running locally.

## Health

`GET /health` → `200 OK`

## Example (delete when you add real ones)

### `POST /summarize`

Request:
```json
{ "text": "Long text to summarize..." }
```

Response `200`:
```json
{ "summary": "Short summary." }
```

Errors: `502` Gemini unavailable.
