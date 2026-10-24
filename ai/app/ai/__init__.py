import functools
import os

from dotenv import load_dotenv

from .base import LLMProvider

load_dotenv()


@functools.lru_cache(maxsize=1)
def get_provider() -> LLMProvider:
    """Pick the provider from LLM_PROVIDER. The instance is cached.

    Raises a clear error if the variable is missing or not one of the
    known names. There is no silent default.
    """
    raw = os.getenv("LLM_PROVIDER")
    if raw is None or not raw.strip():
        raise RuntimeError(
            "LLM_PROVIDER is not set. Set it to 'openai_compat', "
            "'gemini_native', or 'chatgpt_http'."
        )
    name = raw.strip().lower()
    if name == "openai_compat":
        from .openai_compat import OpenAICompatProvider

        return OpenAICompatProvider()
    if name == "gemini_native":
        from .gemini_native import GeminiNativeProvider

        return GeminiNativeProvider()
    if name == "chatgpt_http":
        from .chatgpt_http import ChatGPTHttpProvider

        return ChatGPTHttpProvider()
    raise RuntimeError(
        f"Unknown LLM_PROVIDER: {name!r}. Expected 'openai_compat', "
        "'gemini_native', or 'chatgpt_http'."
    )
