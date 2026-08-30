"""
Child Safety Reviewer prompt (Phase 11).

Dokümandaki "AI Stage 3" ile birebir aynı kontrol listesini kullanıyor.
Bu incelemenin çıktısı iOS'a gönderilen sade SafetyReview modelinden
(reviewed/safe/notes) daha detaylı — issues/severity/rewriteRequired
içeriyor. Detay backend'de kalıyor, iOS'a sadece özet gidiyor
(bkz. app/routers/activity.py).

ÖNEMLİ: Bu reviewer bir güvenlik GARANTİSİ değil — dokümanın da
belirttiği gibi, ebeveyn aktivitenin kendi çocuğuna ve ortamına uygun
olup olmadığını değerlendirmekten nihai olarak sorumlu kalıyor.
"""

import json

from google import genai
from google.genai import types

from app.config import GEMINI_API_KEY
from app.models.schemas import PlayActivity

MODEL_NAME = "gemini-3.6-flash"

SAFETY_SYSTEM_PROMPT = """You are a strict child-safety and appropriateness reviewer \
for PlayBridge AI, an app that suggests short play activities for children aged 3-12.

You will be given the child's age range and a play activity (title, materials, \
setup steps, child instructions, imagination prompts). Check it for ALL of the \
following:

- Age appropriateness for the stated age range
- Dangerous objects, choking hazards, sharp objects
- Fire, electricity, or chemical hazards
- Unsafe climbing or unsupervised outdoor risk
- Inappropriate content for young children
- Medical claims or psychological/developmental diagnosis language
- Shaming or judgmental language toward the parent or child
- Unrealistic developmental assumptions
- Use of materials that were not in the provided materials list
- Whether the activity actually works, and stays safe, in the place the \
parent said they are in (e.g. an activity with small loose pieces or one \
that needs floor space is NOT acceptable "In the car"; anything near the \
stove or knives is NOT acceptable "In the kitchen")
- Privacy problems or unnecessary requests for sensitive personal data

Be strict but fair — most simple activities using ordinary household items \
(paper, crayons, pillows, toys) are safe. Flag an issue only when it is real \
and specific; do not invent hypothetical risks.

Respond with a single JSON object matching the required schema.
"""

SAFETY_RESPONSE_SCHEMA = {
    "type": "object",
    "properties": {
        "safe": {
            "type": "boolean",
            "description": "True if the activity has no safety, ethical, or appropriateness issues.",
        },
        "issues": {
            "type": "array",
            "items": {"type": "string"},
            "description": "Short, specific list of any problems found. Empty if safe.",
        },
        "severity": {
            "type": "string",
            "enum": ["none", "low", "medium", "high"],
            "description": "Overall severity of the issues found. 'none' if safe.",
        },
        "rewriteRequired": {
            "type": "boolean",
            "description": "True if the activity must be regenerated before showing to a parent.",
        },
    },
    "required": ["safe", "issues", "severity", "rewriteRequired"],
}


def _build_activity_text(
    activity: PlayActivity, age_range: str, location: str | None = None
) -> str:
    lines = [f"Child age range: {age_range}"]
    # Mekan, güvenlik değerlendirmesini doğrudan değiştiriyor: oturma
    # odasında masum olan bir oyun arabada tehlikeli olabilir. Bu yüzden
    # reviewer'a da söylüyoruz.
    if location:
        lines.append(f"Parent is currently: {location}")
    lines += [
        f"Activity title: {activity.title}",
        f"Materials: {', '.join(activity.materials)}",
        f"Setup steps: {'; '.join(activity.setup_steps)}",
        f"Child instructions: {'; '.join(activity.child_instructions)}",
        f"Imagination prompts: {'; '.join(activity.imagination_prompts)}",
    ]
    return "\n".join(lines)


def _get_client() -> genai.Client:
    if not GEMINI_API_KEY:
        raise RuntimeError(
            "GEMINI_API_KEY tanımlı değil. Proje kökünde bir .env dosyası "
            "oluşturup GEMINI_API_KEY=... satırını ekleyin "
            "(.env.example dosyasına bakabilirsiniz)."
        )
    return genai.Client(api_key=GEMINI_API_KEY)


async def review_activity(
    activity: PlayActivity, age_range: str, location: str | None = None
) -> dict:
    client = _get_client()

    response = await client.aio.models.generate_content(
        model=MODEL_NAME,
        contents=_build_activity_text(activity, age_range, location),
        config=types.GenerateContentConfig(
            system_instruction=SAFETY_SYSTEM_PROMPT,
            response_mime_type="application/json",
            response_schema=SAFETY_RESPONSE_SCHEMA,
        ),
    )
    return json.loads(response.text)


# --- Hafif metin incelemesi (Meal Mode gibi tek cümlelik çıktılar için) ---
# review_activity() bir PlayActivity nesnesi bekliyor (materials/setupSteps
# vb.) — Meal Mode'da bunların hiçbiri yok, sadece tek bir cümle var. Bu
# yüzden aynı kriterleri çok daha hafif bir şemayla uygulayan ayrı bir
# fonksiyon kullanıyoruz.

TEXT_SAFETY_SYSTEM_PROMPT = """You are a strict child-safety reviewer. You will \
be given a single short sentence meant to be said out loud by a parent to \
their young child. Check whether it is age-appropriate, non-embarrassing, \
non-judgmental, and free of any inappropriate, unsafe, or clinical content.

Respond with a single JSON object matching the required schema.
"""

TEXT_SAFETY_SCHEMA = {
    "type": "object",
    "properties": {
        "safe": {
            "type": "boolean",
            "description": "True if the sentence has no safety or appropriateness issues.",
        },
        "issues": {
            "type": "array",
            "items": {"type": "string"},
            "description": "Short list of problems found, if any. Empty if safe.",
        },
    },
    "required": ["safe", "issues"],
}


async def review_text(text: str) -> dict:
    client = _get_client()

    response = await client.aio.models.generate_content(
        model=MODEL_NAME,
        contents=text,
        config=types.GenerateContentConfig(
            system_instruction=TEXT_SAFETY_SYSTEM_PROMPT,
            response_mime_type="application/json",
            response_schema=TEXT_SAFETY_SCHEMA,
        ),
    )
    return json.loads(response.text)
