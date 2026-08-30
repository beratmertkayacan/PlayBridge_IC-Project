"""
Turn Screen Into Play prompt generator (Phase 14).

Dokümandaki FEATURE 4 (TURN SCREEN INTO PLAY) ile birebir: ekranda
izlenen/izlenmek istenen içeriğin KONUSUNU alıp, o temayı devam
ettiren, ekran gerektirmeyen bir yaratıcı aktiviteye dönüştürür.
Video/görüntü analizi YAPMIYORUZ — sadece ebeveynin yazdığı kısa
konu/başlık metnini kullanıyoruz (dokümanın MVP kapsamı tam olarak bu).

Aynı PlayActivity şemasını ve aynı Safety Reviewer'ı (review_activity)
kullanıyoruz — sadece üretim tarafındaki sistem promptu farklı.
"""

import json
import uuid

from google import genai
from google.genai import types

from app.config import GEMINI_API_KEY
from app.models.schemas import PlayActivity

MODEL_NAME = "gemini-3.6-flash"

SYSTEM_PROMPT = """You are a creative assistant embedded in PlayBridge AI. A \
parent tells you the topic of a video or show their child has watched or \
wants to watch. Your job is to transform that SAME topic into one single, \
delightful, screen-free creative activity that extends the child's interest \
into imaginative offline play — connecting what they watched to something \
they can now CREATE.

Rules:
- Assume only simple, commonly available materials unless the activity needs \
none at all: paper, pencil or crayons, or just imagination/talking. Never \
assume the parent has anything unusual or specific.
- Keep every instruction short and concrete — a tired parent should be able \
to read it in a few seconds. Never write long paragraphs.
- The activity must be safe and age-appropriate for the stated age range.
- Never use clinical, developmental, or diagnostic language.
- The "summary" field must briefly explain how this activity connects to the \
video topic and why it fits — it is shown to the parent as "Why it fits".
- "childInstructions" and "imaginationPrompts" together should feel like a \
short chain of creative prompts (e.g., "Draw a dinosaur that has never \
existed." / "What does it eat?" / "Where does it live?" / "Give it a name.") \
— this is the heart of the activity.
- screenRequired must always be false.
- Respond with a single JSON object matching the required schema. Do not \
include any text outside the JSON.

Example (for calibrating TONE only — never reuse this content):
Topic: "Dinosaurs for Kids", age range: 5-6.
Example output:
{"title": "Invent a New Dinosaur", "summary": "Turns their dinosaur video into \
a hands-on invention game using just paper and crayons.", "materials": \
["paper", "crayons"], "setupSteps": ["Hand them paper and crayons."], \
"childInstructions": ["Draw a dinosaur that has never existed.", "Give it a \
name."], "imaginationPrompts": ["What does it eat?", "Where does it live?", \
"What special ability does it have?"], "screenRequired": false}
"""

ACTIVITY_RESPONSE_SCHEMA = {
    "type": "object",
    "properties": {
        "title": {"type": "string", "description": "Short, fun activity name."},
        "summary": {
            "type": "string",
            "description": "1-2 sentences: how this connects to the video topic and why it fits.",
        },
        "materials": {
            "type": "array",
            "items": {"type": "string"},
            "description": "Simple, commonly available materials only (or empty if none needed).",
        },
        "setupSteps": {
            "type": "array",
            "items": {"type": "string"},
            "description": "Very short parent setup steps (max ~3).",
        },
        "childInstructions": {
            "type": "array",
            "items": {"type": "string"},
            "description": "Very short child instructions (max ~3), extending the video's topic.",
        },
        "imaginationPrompts": {
            "type": "array",
            "items": {"type": "string"},
            "description": "2-3 short open-ended follow-up questions.",
        },
        "screenRequired": {"type": "boolean", "description": "Always false."},
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


def _get_client() -> genai.Client:
    if not GEMINI_API_KEY:
        raise RuntimeError(
            "GEMINI_API_KEY tanımlı değil. Proje kökünde bir .env dosyası "
            "oluşturup GEMINI_API_KEY=... satırını ekleyin."
        )
    return genai.Client(api_key=GEMINI_API_KEY)


async def generate_screen_to_play(
    age_range: str, screen_topic: str, extra_guidance: str | None = None
) -> PlayActivity:
    client = _get_client()

    request_text = f"Video/content topic: {screen_topic}\nChild age range: {age_range}"
    if extra_guidance:
        request_text += (
            f"\n\nIMPORTANT: a previous attempt was flagged for the following "
            f"reason(s): {extra_guidance}. Generate a new activity that clearly "
            f"avoids this problem."
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
        setupTimeMinutes=2,
        activityTimeMinutes=15,
        materials=data["materials"],
        setupSteps=data["setupSteps"],
        childInstructions=data["childInstructions"],
        imaginationPrompts=data["imaginationPrompts"],
        screenRequired=data["screenRequired"],
    )
