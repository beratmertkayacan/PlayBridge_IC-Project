"""
Meal Mode prompt generator (Phase 13).

Dokümandaki FEATURE 3 (MEAL MODE) ile birebir: TEK, kısa, ekran ve
malzeme gerektirmeyen bir ebeveyn-çocuk sohbet açıcısı üretir.
Uzun metin YOK, çoklu adım YOK, sohbet YOK — sadece tek bir cümle.
"""

import json

from google import genai
from google.genai import types

from app.config import GEMINI_API_KEY

MODEL_NAME = "gemini-3.6-flash"

SYSTEM_PROMPT = """You generate ONE short, playful conversation-starter or tiny \
game for a parent to say out loud to their child (ages 3-12) during a meal — no \
screens, no materials, nothing to set up.

Rules:
- Exactly one short sentence. No explanation, no extra text.
- Must be something the parent can literally read and say immediately.
- Age-appropriate, fun, imaginative — never clinical, never a question that \
could embarrass the child.
- Vary the style across calls: sometimes an observation game ("Can you find \
three red things on the table?"), sometimes a silly hypothetical ("If your \
carrot could talk, what would it say?"), sometimes a tiny story starter \
("Let's make up a three-word story together. You start!").

Respond with a single JSON object matching the required schema.
"""

MEAL_PROMPT_SCHEMA = {
    "type": "object",
    "properties": {
        "prompt": {
            "type": "string",
            "description": "The single short sentence the parent will say out loud.",
        },
    },
    "required": ["prompt"],
}


def _get_client() -> genai.Client:
    if not GEMINI_API_KEY:
        raise RuntimeError(
            "GEMINI_API_KEY tanımlı değil. Proje kökünde bir .env dosyası "
            "oluşturup GEMINI_API_KEY=... satırını ekleyin."
        )
    return genai.Client(api_key=GEMINI_API_KEY)


async def generate_meal_prompt(age_range: str) -> str:
    client = _get_client()

    response = await client.aio.models.generate_content(
        model=MODEL_NAME,
        contents=f"Child age range: {age_range}",
        config=types.GenerateContentConfig(
            system_instruction=SYSTEM_PROMPT,
            response_mime_type="application/json",
            response_schema=MEAL_PROMPT_SCHEMA,
        ),
    )
    data = json.loads(response.text)
    return data["prompt"]
