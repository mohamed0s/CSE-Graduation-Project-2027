# Finda AI Service

## What this is
The AI "brain" of Finda (formerly Rafiq), a platform that matches users to
local services (search, budget recommendations, space ideas, orders, order
tracking) from natural requests in Egyptian Arabic, Franco-Arabic, or English.

## Architecture
- A .NET backend handles auth, the database, and search/ranking.
- THIS service (Python + FastAPI) understands the request, manages the
  conversation, asks clarifying questions, and decides when to search.
- This service NEVER touches the database. It calls POST /search on the
  .NET backend.

## Rules
- Use an abstraction (LLMProvider) so we can switch from a commercial
  LLM to an open-source model by changing config only.
- Do not use provider-specific tool calling. Ask for JSON, validate
  with Pydantic, retry on failure.
- API keys and URLs live in .env, never in code.
- Keep code simple and commented. Work in small steps.
- NEVER open, read, print, or copy the contents of .env. Only edit
  .env.example. I manage .env myself.