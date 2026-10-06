# AI Service (Gemini API)

**Owner:** AI team

A small Python (FastAPI) service that wraps the Gemini API.
The backend calls this service; the apps never call Gemini directly.
This keeps the API key on the server and all prompts in one place.

## Setup (first time only)

```bash
cd ai
python -m venv .venv
# Windows: .venv\Scripts\activate   |   macOS/Linux: source .venv/bin/activate
pip install fastapi "uvicorn[standard]" google-genai python-dotenv
pip freeze > requirements.txt
```

Create a `.env` file (git-ignored) with `GEMINI_API_KEY=...`, and commit a `.env.example` with the same
variable names but fake values so teammates know what to set.

Get a key from https://aistudio.google.com/apikey

## Suggested layout

```
ai/
├── app/
│   ├── main.py       # FastAPI app + routes
│   ├── gemini.py     # all Gemini calls live here
│   └── prompts/      # prompt templates (.md / .txt)
├── tests/            # mock Gemini in tests - no real API calls in CI
├── requirements.txt
├── .env.example      # variable names only, no real values
└── Dockerfile
```

## Run

```bash
uvicorn app.main:app --reload --port 8000
# Docs: http://localhost:8000/docs
```

## Notes

- **Never commit `.env` or your API key.**
- Add a `GET /health` endpoint.
- Document your endpoints in [`docs/api/ai.md`](../docs/api/ai.md) so the backend team knows how to call you.
