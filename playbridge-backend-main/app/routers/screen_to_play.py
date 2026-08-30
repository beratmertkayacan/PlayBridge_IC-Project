import logging

from fastapi import APIRouter

from app.models.schemas import (
    GeneratedActivityResponse,
    PlayActivity,
    SafetyReview,
    ScreenToPlayRequest,
)
from app.prompts.safety_reviewer import review_activity
from app.prompts.screen_to_play_generator import generate_screen_to_play

logger = logging.getLogger("playbridge.screen_to_play")

router = APIRouter(prefix="/api/v1/screen-to-play", tags=["screen-to-play"])


def _mock_activity(topic: str) -> GeneratedActivityResponse:
    first_word = topic.split()[0].capitalize() if topic.split() else "World"
    activity = PlayActivity(
        id="mock-screen-to-play",
        title=f"Invent Your Own {first_word}",
        summary=f"Turns the '{topic}' topic into a hands-on drawing and imagination game.",
        setupTimeMinutes=2,
        activityTimeMinutes=15,
        materials=["paper", "crayons"],
        setupSteps=["Hand them paper and crayons."],
        childInstructions=[
            "Draw your own version of what you just watched.",
            "Give it a name.",
        ],
        imaginationPrompts=[
            "What does it do?",
            "Where does it live?",
            "What makes it special?",
        ],
        screenRequired=False,
    )
    safety = SafetyReview(reviewed=True, safe=True, notes=[])
    return GeneratedActivityResponse(activity=activity, safety=safety)


@router.post("/generate", response_model=GeneratedActivityResponse)
async def generate_screen_to_play_endpoint(
    request: ScreenToPlayRequest,
) -> GeneratedActivityResponse:
    try:
        activity = await generate_screen_to_play(request.age_range, request.screen_topic)
        review = await review_activity(activity, request.age_range)

        if review.get("rewriteRequired"):
            feedback = "; ".join(review.get("issues", [])) or "unspecified concern"
            activity = await generate_screen_to_play(
                request.age_range, request.screen_topic, extra_guidance=feedback
            )
            review = await review_activity(activity, request.age_range)

        if review.get("rewriteRequired") or not review.get("safe", True):
            logger.warning(
                "Screen-to-play çıktısı güvenlik incelemesinden geçemedi, "
                "mock'a düşülüyor: %s",
                review.get("issues"),
            )
            return _mock_activity(request.screen_topic)

        logger.info(
            "Gemini'den gerçek screen-to-play aktivitesi üretildi: %s", activity.title
        )
        safety = SafetyReview(reviewed=True, safe=True, notes=[])
        return GeneratedActivityResponse(activity=activity, safety=safety)

    except Exception as e:
        logger.warning("Screen-to-play üretimi başarısız, mock'a düşülüyor: %s", e)
        return _mock_activity(request.screen_topic)
