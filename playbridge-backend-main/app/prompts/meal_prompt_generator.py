"""
Meal Mode prompt generator (Phase 13).

Dokümandaki FEATURE 3 (MEAL MODE) ile birebir: TEK, kısa, ekran ve
malzeme gerektirmeyen bir ebeveyn-çocuk sohbet açıcısı üretir.
Uzun metin YOK, çoklu adım YOK, sohbet YOK — sadece tek bir cümle.
"""

import json

from google import genai
from google.genai import types

from app.config import GEMINI_API_KEY, GEMINI_MODEL

MODEL_NAME = GEMINI_MODEL

SYSTEM_PROMPT = """You generate ONE short, playful conversation-starter or tiny \
game for a parent to say out loud to their child (ages 3-12) during a meal — no \
screens, no materials, nothing to set up.

Rules:
- Exactly one short sentence. No explanation, no extra text.
- Must be something the parent can literally read and say immediately.
- Age-appropriate, fun, imaginative — never clinical, never a question that \
could embarrass the child.
- If a topic is given, the question MUST be about that topic and about things \
that are within reach at the table right now:
  "table" — objects actually on the table in front of them.
  "kitchen" — things in the kitchen around them.
  "food" — the food on their plate.
  "story" — a tiny story or something from their day; needs no objects.
- Scale the question to the age range. For ages 3-6 ask something they can \
see, count, or point at. For 7-9 ask them to guess, compare, or explain. For \
10-12 ask something with no single right answer that invites a real opinion — \
never something that would feel babyish to them.
- Vary the style across calls: sometimes an observation game, sometimes a \
silly hypothetical, sometimes a tiny story starter.

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


async def generate_meal_prompt(age_range: str, category: str | None = None) -> str:
    client = _get_client()

    contents = f"Child age range: {age_range}"
    if category:
        contents += f"\nTopic: {category}"

    response = await client.aio.models.generate_content(
        model=MODEL_NAME,
        contents=contents,
        config=types.GenerateContentConfig(
            system_instruction=SYSTEM_PROMPT,
            response_mime_type="application/json",
            response_schema=MEAL_PROMPT_SCHEMA,
        ),
    )
    data = json.loads(response.text)
    return data["prompt"]
