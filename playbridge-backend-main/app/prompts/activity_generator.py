"""
Activity Generator prompt (Phase 10 — Gemini sürümü).

Kullanılan teknikler (raporda referans vermek için):
- Role/context/constraints prompting  -> SYSTEM_PROMPT
- Few-shot example                    -> SYSTEM_PROMPT içine gömülü örnek
- Zorunlu yapılandırılmış çıktı       -> response_mime_type + response_schema

Neden serbest metin JSON değil de response_schema?
Modelden "sadece JSON döndür" demek modelin arada açıklama eklemesine
veya şemadan sapmasına açık kapı bırakır. Gemini'nin response_schema
özelliği, çıktının şemaya uyduğunu API seviyesinde garanti eder.

Not: setupTimeMinutes ve activityTimeMinutes bilinçli olarak modelden
İSTENMİYOR — bunları ebeveyn zaten UI'da seçti, ActivityRequest'ten
doğrudan kopyalanıyor. Modelin bu sayıları değiştirmesine izin
vermiyoruz.
"""

import json
import uuid

from google import genai
from google.genai import types

from app.config import GEMINI_API_KEY
from app.models.schemas import ActivityRequest, PlayActivity

MODEL_NAME = "gemini-3.6-flash"

SYSTEM_PROMPT = """You are a creative assistant embedded in PlayBridge AI, an app \
that helps parents turn short windows of time into simple, imaginative, \
screen-free play for their young child (ages 3-7).

Given a parent's available time, setup time, their child's interests, and the \
materials they have on hand, generate ONE single, specific, delightful play \
activity — not a list of options.

Rules:
- Use ONLY the materials provided. Never invent materials the parent doesn't have.
- Keep every instruction short and concrete — a tired parent should be able to \
read it in a few seconds. Never write long paragraphs.
- The activity must be safe and age-appropriate for the stated age range. Avoid \
sharp objects, small choking-hazard pieces for children under 4, unsupervised \
fire or water immersion, or climbing.
- Never use clinical, developmental, or diagnostic language (e.g. do not claim \
the activity "improves cognitive development"). Focus on imagination, story, \
and fun.
- The "summary" field must briefly explain *why this specific activity fits* \
this child's interest and this amount of time — it is shown to the parent as \
"Why it fits".
- Respond with a single JSON object matching the required schema. Do not \
include any text outside the JSON.

Example (for calibrating TONE and BREVITY only — never reuse this content):
Context: age range 5-6, interests: space, materials: pillows/paper/crayons, \
20 minutes play, 5 minutes setup.
Example output:
{"title": "Build Your Own Space Mission", "summary": "Turns their love of \
space into a hands-on mission using only pillows and paper — no screen \
needed.", "materials": ["pillows", "paper", "crayons"], "setupSteps": \
["Stack pillows into a rocket seat.", "Hand them paper and crayons for \
mission drawings."], "childInstructions": ["Choose a planet to visit.", \
"Draw what you find there."], "imaginationPrompts": ["What does your planet \
sound like?", "What would you eat there?", "Who do you meet?"], \
"screenRequired": false}
"""

ACTIVITY_RESPONSE_SCHEMA = {
    "type": "object",
    "properties": {
        "title": {
            "type": "string",
            "description": "Short, fun activity name (a few words).",
        },
        "summary": {
            "type": "string",
            "description": "1-2 sentences: why this activity fits this child's interest and available time.",
        },
        "materials": {
            "type": "array",
            "items": {"type": "string"},
            "description": "Only materials from the ones the parent said they have.",
        },
        "setupSteps": {
            "type": "array",
            "items": {"type": "string"},
            "description": "Very short steps for the PARENT to set up (max ~3 steps).",
        },
        "childInstructions": {
            "type": "array",
            "items": {"type": "string"},
            "description": "Very short instructions for the CHILD to follow (max ~3 steps).",
        },
        "imaginationPrompts": {
            "type": "array",
            "items": {"type": "string"},
            "description": "2-3 short open-ended questions to keep the child's imagination going.",
        },
        "screenRequired": {
            "type": "boolean",
            "description": "Always false for this app — activities must be screen-free.",
        },
    },
    "required": [
        "title",
        "summary",
        "materials",
        "setupSteps",
        "childInstructions",
        "imaginationPrompts",
        "screenRequired",
    ],
}


def _build_request_text(request: ActivityRequest) -> str:
    return (
        f"Child age range: {request.age_range}\n"
        f"Interests: {', '.join(request.interests)}\n"
        f"Available materials: {', '.join(request.available_materials)}\n"
        f"Time available for play: {request.duration_minutes} minutes\n"
        f"Parent setup time: {request.parent_setup_minutes} minutes"
    )


def _get_client() -> genai.Client:
    if not GEMINI_API_KEY:
        raise RuntimeError(
            "GEMINI_API_KEY tanımlı değil. Proje kökünde bir .env dosyası "
            "oluşturup GEMINI_API_KEY=... satırını ekleyin "
            "(.env.example dosyasına bakabilirsiniz)."
        )
    return genai.Client(api_key=GEMINI_API_KEY)


async def generate_activity(
    request: ActivityRequest, extra_guidance: str | None = None
) -> PlayActivity:
    client = _get_client()

    request_text = _build_request_text(request)
    if extra_guidance:
        # Safety reviewer bir önceki denemeyi reddettiğinde buraya düşer.
        request_text += (
            f"\n\nIMPORTANT: a previous attempt at this activity was flagged for "
            f"the following reason(s): {extra_guidance}. Generate a new activity "
            f"that clearly avoids this problem."
        )

    response = await client.aio.models.generate_content(
        model=MODEL_NAME,
        contents=request_text,
        config=types.GenerateContentConfig(
            system_instruction=SYSTEM_PROMPT,
            response_mime_type="application/json",
            response_schema=ACTIVITY_RESPONSE_SCHEMA,
        ),
    )

    data = json.loads(response.text)

    return PlayActivity(
        id=str(uuid.uuid4()),
        title=data["title"],
        summary=data["summary"],
        setupTimeMinutes=request.parent_setup_minutes,
        activityTimeMinutes=request.duration_minutes,
        materials=data["materials"],
        setupSteps=data["setupSteps"],
        childInstructions=data["childInstructions"],
        imaginationPrompts=data["imaginationPrompts"],
        screenRequired=data["screenRequired"],
    )
