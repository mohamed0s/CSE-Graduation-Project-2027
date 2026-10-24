from __future__ import annotations

import os
from typing import List

import httpx

from .base import LLMProvider, Message
from .usage import record_provider_call


class OpenAICompatProvider(LLMProvider):
    """Talks to any OpenAI-compatible chat-completions endpoint."""

    def __init__(self) -> None:
        self.base_url = os.getenv("LLM_BASE_URL", "").rstrip("/")
        self.api_key = os.getenv("LLM_API_KEY", "")
        self.model = os.getenv("LLM_MODEL", "")
        if not (self.base_url and self.api_key and self.model):
            raise RuntimeError(
                "LLM_BASE_URL, LLM_API_KEY and LLM_MODEL must be set for openai_compat"
            )

    async def complete(self, system: str, messages: List[Message]) -> str:
        record_provider_call()
        payload = {
            "model": self.model,
            "messages": [{"role": "system", "content": system}, *messages],
            "temperature": 0.2,
        }
        headers = {"Authorization": f"Bearer {self.api_key}"}
        async with httpx.AsyncClient(timeout=60) as client:
            resp = await client.post(
                f"{self.base_url}/chat/completions", json=payload, headers=headers
            )
            resp.raise_for_status()
            data = resp.json()
        return data["choices"][0]["message"]["content"]
