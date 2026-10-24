"""HTTP API for Finda's parser. Stateless. Does not touch the database
and does not call the .NET backend.
"""

from __future__ import annotations

import asyncio
import logging
import os
import uuid
from typing import Literal

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from app.ai.errors import AIServiceError
from app.ai.parser import parse_request
from app.ai.reliability import rate_limiter, request_timeout_seconds, user_bucket
from app.ai.schemas import ExtractionResult

logger = logging.getLogger(__name__)

app = FastAPI(title="Finda AI", version="0.1.0")


class HistoryMessage(BaseModel):
    role: Literal["user", "assistant"]
    content: str = Field(max_length=1000)


class ParseRequest(BaseModel):
    text: str = Field(max_length=1000)
    history: list[HistoryMessage] = Field(default_factory=list, max_length=6)


class ParseResponse(ExtractionResult):
    """ExtractionResult plus what the caller should do next."""

    next_action: Literal["ask_user", "reply", "ready"]


@app.middleware("http")
async def add_request_id(request: Request, call_next):
    """Copy X-Request-ID or mint one. Log the id, never the body."""
    incoming = request.headers.get("X-Request-ID", "").strip()
    request_id = incoming if incoming and len(incoming) <= 200 else str(uuid.uuid4())
    request.state.request_id = request_id
    logger.info(
        "request_id=%s method=%s path=%s",
        request_id,
        request.method,
        request.url.path,
    )
    response = await call_next(request)
    response.headers["X-Request-ID"] = request_id
    return response


@app.exception_handler(AIServiceError)
async def ai_unavailable(request: Request, exc: AIServiceError):
    """Do not return the provider exception, key, or prompt."""
    request_id = getattr(request.state, "request_id", "")
    logger.error(
        "request_id=%s ai_unavailable error_type=%s",
        request_id,
        type(exc).__name__,
    )
    return JSONResponse(
        status_code=503,
        content={"error": "ai_unavailable"},
        headers={"X-Request-ID": request_id} if request_id else None,
    )


@app.exception_handler(Exception)
async def unhandled(request: Request, exc: Exception):
    """Hide unexpected errors. Validation errors keep their own 422 handler."""
    request_id = getattr(request.state, "request_id", "")
    logger.error(
        "request_id=%s unhandled error_type=%s",
        request_id,
        type(exc).__name__,
    )
    return JSONResponse(
        status_code=500,
        content={"error": "internal"},
        headers={"X-Request-ID": request_id} if request_id else None,
    )


@app.get("/health")
async def health():
    """The process is up. Does not check providers."""
    return {"status": "ok"}


@app.get("/ready")
async def ready():
    """Config is present. Does not call any provider."""
    missing = _missing_config()
    if missing:
        return JSONResponse(
            status_code=503,
            content={"ready": False, "missing": missing},
        )
    return {"ready": True}


@app.post("/parse", response_model=ParseResponse)
async def parse(body: ParseRequest, request: Request):
    """Classify and extract. The caller sends the recent history."""
    retry_after = rate_limiter.retry_after(user_bucket(request.headers.get("X-User-Id")))
    if retry_after is not None:
        return JSONResponse(
            status_code=429,
            content={"error": "rate_limited"},
            headers={"Retry-After": str(retry_after)},
        )
    history = [item.model_dump() for item in body.history]
    try:
        result = await asyncio.wait_for(
            parse_request(body.text, history),
            timeout=request_timeout_seconds(),
        )
    except TimeoutError:
        # Budget exceeded. The inner task is already cancelled.
        raise AIServiceError("request timed out")
    return ParseResponse(
        **result.model_dump(),
        next_action=_next_action(result),
    )


def _next_action(result: ExtractionResult) -> Literal["ask_user", "reply", "ready"]:
    if result.clarifying_question:
        return "ask_user"
    if result.reply_text:
        return "reply"
    return "ready"


def _missing_config() -> list[str]:
    """Names of required env vars that are unset. Never the values."""
    missing: list[str] = []
    classifier = os.getenv("CLASSIFIER_PROVIDER", "").strip().lower()
    provider = os.getenv("LLM_PROVIDER", "").strip().lower()
    if classifier not in ("jev", "gemini"):
        missing.append("CLASSIFIER_PROVIDER")
    if provider == "gemini_native":
        if not os.getenv("LLM_API_KEY", "").strip():
            missing.append("LLM_API_KEY")
    elif provider == "openai_compat":
        for name in ("LLM_BASE_URL", "LLM_API_KEY", "LLM_MODEL"):
            if not os.getenv(name, "").strip():
                missing.append(name)
    elif provider == "chatgpt_http":
        if not os.getenv("CHATGPT_URL", "").strip():
            missing.append("CHATGPT_URL")
    else:
        missing.append("LLM_PROVIDER")
    if classifier == "jev":
        for name in ("TYPESAFE_API_KEY", "JEV_MODEL"):
            if not os.getenv(name, "").strip():
                missing.append(name)
    return missing
