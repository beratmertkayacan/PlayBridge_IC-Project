import logging
import uuid

from fastapi import APIRouter

from app.models.schemas import (
    ActivityRequest,
    GeneratedActivityResponse,
    PlayActivity,
    SafetyReview,
)
from app.prompts.activity_generator import generate_activity
from app.prompts.safety_reviewer import review_activity
from app.prompts.together_generator import generate_together_activity

logger = logging.getLogger("playbridge.activity")

router = APIRouter(prefix="/api/v1/activity", tags=["activity"])


def generate_mock_activity(request: ActivityRequest) -> GeneratedActivityResponse:
    """
    Elle yazılmış, bilinen güvenli mock. AI çağrısı düşerse veya güvenlik
    incelemesi iki denemede de geçemezse buraya düşülür.
    """
    if (
        request.mode == "together"
        and request.location == "In the car"
        and not request.available_materials
    ):
        return _car_window_mock(request)

    primary_interest = request.interests[0] if request.interests else "imagination"
    title = f"{primary_interest.capitalize()} Adventure"

    activity = PlayActivity(
        id=str(uuid.uuid4()),
        title=title,
        summary=f"A simple {primary_interest.lower()}-themed activity your child can enjoy independently.",
        setup_time_minutes=request.parent_setup_minutes,
        activity_time_minutes=request.duration_minutes,
        materials=request.available_materials,
        setup_steps=[
            "Gather the materials in one spot.",
            "Set the scene with a short, simple story hook.",
        ],
        child_instructions=[
            f"Explore the {primary_interest.lower()} world you've set up.",
            "Invent a short story about what happens next.",
        ],
        imagination_prompts=[
            "What do you see?",
            "What happens next?",
            "How does the story end?",
        ],
        screen_required=False,
    )

    safety = SafetyReview(reviewed=True, safe=True, notes=[])
    return GeneratedActivityResponse(activity=activity, safety=safety)


def _car_window_mock(request: ActivityRequest) -> GeneratedActivityResponse:
    activity = PlayActivity(
        id=str(uuid.uuid4()),
        title="Red Car Hunt",
        summary="A looking game you play from your seats. Nothing in your hands. Just the view out the window.",
        setup_time_minutes=request.parent_setup_minutes,
        activity_time_minutes=request.duration_minutes,
        materials=[],
        setup_steps=[
            "Stay buckled. Look out the windows together.",
        ],
        child_instructions=[
            "Count every red car you see.",
            "Then switch: find a blue car, then a truck.",
        ],
        imagination_prompts=[
            "Where do you think that red car is going?",
            "What would a giant truck say if it could talk?",
            "Can you spot something the same color as your shirt?",
        ],
        screen_required=False,
    )
    safety = SafetyReview(reviewed=True, safe=True, notes=[])
    return GeneratedActivityResponse(activity=activity, safety=safety)


async def _generate(request: ActivityRequest, extra_guidance: str | None = None) -> PlayActivity:
    """
    Dokümanın önerdiği 'tek orkestre eden endpoint' fikri: hangi
    üreticinin çalışacağına burada, request.mode'a bakarak karar
    veriyoruz. Yeni bir mod eklemek istersek (örn. ileride başka bir
    tarz), sadece burayı genişletmemiz yeterli.
    """
    if request.mode == "together":
        return await generate_together_activity(request, extra_guidance=extra_guidance)
    return await generate_activity(request, extra_guidance=extra_guidance)


@router.post("/generate", response_model=GeneratedActivityResponse)
async def generate_activity_endpoint(request: ActivityRequest) -> GeneratedActivityResponse:
    try:
        activity = await _generate(request)
        review = await review_activity(activity, request.age_range, request.location)

        if review.get("rewriteRequired"):
            logger.info(
                "Safety reviewer yeniden üretim istedi: %s", review.get("issues")
            )
            feedback = "; ".join(review.get("issues", [])) or "unspecified concern"
            activity = await _generate(request, extra_guidance=feedback)
            review = await review_activity(activity, request.age_range, request.location)

        if review.get("rewriteRequired") or not review.get("safe", True):
            logger.warning(
                "AI çıktısı ikinci denemede de güvenlik incelemesinden "
                "geçemedi, mock'a düşülüyor: %s",
                review.get("issues"),
            )
            return generate_mock_activity(request)

        logger.info(
            "Gemini'den gerçek, güvenlik onaylı aktivite üretildi (mode=%s): %s",
            request.mode,
            activity.title,
        )
        safety = SafetyReview(reviewed=True, safe=True, notes=[])
        return GeneratedActivityResponse(activity=activity, safety=safety)

    except Exception as e:
        logger.warning("AI üretimi başarısız, mock'a düşülüyor: %s", e)
        return generate_mock_activity(request)
