"""
Let's Play Together prompt generator.

Dokümandaki FEATURE 2 (LET'S PLAY TOGETHER) ile birebir: ebeveynin
ÇOCUKLA BİRLİKTE oynayacağı, işbirliğine ve iletişime dayalı bir
aktivite üretir — Activity Generator'daki (Phase 10) "bağımsız oyun"
vurgusunun tam tersi.

Aynı ActivityRequest girdisini, aynı PlayActivity çıktı şemasını ve
aynı Safety Reviewer'ı (review_activity) kullanıyor — sadece sistem
promptu farklı. app/routers/activity.py, request.mode alanına göre
bu fonksiyon ile activity_generator.generate_activity() arasında
seçim yapıyor (dokümanın önerdiği "tek orkestre eden endpoint" fikri).
"""

import json
import uuid

from google import genai
from google.genai import types

from app.config import GEMINI_API_KEY
from app.models.schemas import ActivityRequest, PlayActivity

MODEL_NAME = "gemini-3.6-flash"

SYSTEM_PROMPT = """You are a creative assistant embedded in PlayBridge AI. \
Unlike the "independent play" mode, this activity is for a PARENT WHO WANTS \
TO ACTIVELY PLAY ALONGSIDE their child, not hand off and leave.

Given the child's age range, interests, available materials, and the time \
the parent has to spend together, generate ONE single collaborative activity \
that both parent and child do TOGETHER.

Rules:
- Use ONLY the materials provided. Never invent materials the parent doesn't have.
- Emphasize collaboration, storytelling, communication, and shared \
imagination — the parent should be an active participant, not a bystander.
- "childInstructions" should read as things the PARENT AND CHILD do \
TOGETHER (e.g. "Build a spaceship together using the pillows."), never as \
solo child tasks.
- "imaginationPrompts" should be open-ended questions the PARENT asks the \
CHILD during the activity, to keep the conversation and imagination going \
(e.g. "What lives there?", "What does it sound like?").
- Keep every instruction short and concrete. Never write long paragraphs.
- The activity must be safe and age-appropriate for the stated age range.
- Scale the activity to the stated age range. For ages 3-6 keep it to one \
simple idea with very few steps. For 7-9 add a small challenge or a rule. \
For 10-12 the child is capable and easily bored: give a real constraint, a \
problem to solve, or something to build over the whole time — never \
something that would feel babyish to them.
- The parent may tell you WHERE they are right now. If they do, the \
activity must actually work in that place, using only what is reachable \
there. "In the car": everything must work from a seat with the belt on — \
no spreading out, nothing that rolls away or drops into a footwell, no \
small loose pieces, no standing, and never anything that pulls the \
driver's attention. "In the kitchen": keep the child clear of the stove, \
hot surfaces, knives and anything that can spill or burn. "Outdoor": no \
unsupervised water, no climbing, nothing that blows away. "Living room": \
ordinary floor play is fine. If no place is given, assume an ordinary \
room at home.
- Never use clinical, developmental, or diagnostic language.
- The "summary" field must briefly explain why this activity fits and how \
it encourages parent-child connection — shown to the parent as "Why it fits".
- screenRequired must always be false.
- Respond with a single JSON object matching the required schema. Do not \
include any text outside the JSON.

Example (for calibrating TONE only — never reuse this content):
Context: age 5-6, interest: space, materials: pillows/paper/crayons, 20 \
minutes together.
Example output:
{"title": "Build Your Own Space Mission", "summary": "A hands-on mission you \
build and imagine together, turning pillows into a spaceship.", "materials": \
["pillows", "paper", "crayons"], "setupSteps": ["Clear a small space on the \
floor together."], "childInstructions": ["Build a spaceship together using \
the pillows.", "Draw the planet you're about to visit together."], \
"imaginationPrompts": ["What lives there?", "What does the planet sound \
like?", "What would you eat there?"], "screenRequired": false}
"""

ACTIVITY_RESPONSE_SCHEMA = {
    "type": "object",
    "properties": {
        "title": {"type": "string", "description": "Short, fun activity name."},
        "summary": {
            "type": "string",
            "description": "1-2 sentences: why this fits and how it encourages parent-child connection.",
        },
        "materials": {
            "type": "array",
            "items": {"type": "string"},
            "description": "Only materials from the ones the parent said they have.",
        },
        "setupSteps": {
            "type": "array",
            "items": {"type": "string"},
            "description": "Very short joint setup steps (max ~3).",
        },
        "childInstructions": {
            "type": "array",
            "items": {"type": "string"},
            "description": "Things the parent AND child do TOGETHER (max ~3).",
        },
        "imaginationPrompts": {
            "type": "array",
            "items": {"type": "string"},
            "description": "2-3 questions the parent asks the child during play.",
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


def _build_request_text(request: ActivityRequest) -> str:
    lines = [
        f"Child age range: {request.age_range}",
        f"Interests: {', '.join(request.interests)}",
        f"Available materials: {', '.join(request.available_materials)}",
        f"Time available together: {request.duration_minutes} minutes",
    ]
    if request.location:
        lines.append(f"Parent is currently: {request.location}")
    return "\n".join(lines)


async def generate_together_activity(
    request: ActivityRequest, extra_guidance: str | None = None
) -> PlayActivity:
    client = _get_client()

    request_text = _build_request_text(request)
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
        setupTimeMinutes=request.parent_setup_minutes,
        activityTimeMinutes=request.duration_minutes,
        materials=data["materials"],
        setupSteps=data["setupSteps"],
        childInstructions=data["childInstructions"],
        imaginationPrompts=data["imaginationPrompts"],
        screenRequired=data["screenRequired"],
    )
