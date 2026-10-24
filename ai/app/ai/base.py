from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any, Dict, List

# A message is a plain dict: {"role": "user" | "assistant", "content": str}
Message = Dict[str, Any]


class LLMProvider(ABC):
    """Abstraction over any LLM backend (commercial or self-hosted OSS)."""

    @abstractmethod
    async def complete(self, system: str, messages: List[Message]) -> str:
        """Send `system` + chat `messages` and return the raw text reply."""
        raise NotImplementedError
