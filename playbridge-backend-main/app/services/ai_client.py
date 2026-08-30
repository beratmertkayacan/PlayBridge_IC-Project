from google import genai

from app.config import GEMINI_API_KEY, GEMINI_MODEL

# Ücretsiz katmanda (günde 1.500 istek, kredi kartı gerektirmez) mevcut model.
MODEL_NAME = GEMINI_MODEL


def _get_client() -> genai.Client:
    if not GEMINI_API_KEY:
        raise RuntimeError(
            "GEMINI_API_KEY tanımlı değil. Proje kökünde bir .env dosyası "
            "oluşturup GEMINI_API_KEY=... satırını ekleyin "
            "(.env.example dosyasına bakabilirsiniz)."
        )
    return genai.Client(api_key=GEMINI_API_KEY)


async def ping() -> str:
    """
    Basit bir bağlantı testi — Gemini'ye küçük bir istek atar, dönen
    metni aynen geri verir.
    """
    client = _get_client()
    response = await client.aio.models.generate_content(
        model=MODEL_NAME,
        contents="Reply with exactly one word: connected",
    )
    return response.text.strip()
