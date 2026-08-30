import logging
import random

from fastapi import APIRouter

from app.models.schemas import MealPromptRequest, MealPromptResponse
from app.prompts.meal_prompt_generator import generate_meal_prompt
from app.prompts.safety_reviewer import review_text

logger = logging.getLogger("playbridge.meal")

router = APIRouter(prefix="/api/v1/meal", tags=["meal"])

# AI çağrısı başarısız olursa ya da güvenlik incelemesinden geçemezse
# (demo güvenliği) elle yazılmış, bilinen güvenli bir listeden rastgele
# seçiyoruz — Activity Generator'daki aynı mock-fallback felsefesi.
_FALLBACK_PROMPTS = [
    "Can you find three red things on the table?",
    "If your fork could talk, what would it say?",
    "Let's make up a three-word story together. You start!",
]


@router.post("/prompt", response_model=MealPromptResponse)
async def get_meal_prompt(request: MealPromptRequest) -> MealPromptResponse:
    try:
        prompt = await generate_meal_prompt(request.age_range)
        review = await review_text(prompt)

        if not review.get("safe", True):
            logger.warning(
                "Meal prompt güvenlik incelemesinden geçemedi, sabit "
                "listeye düşülüyor: %s",
                review.get("issues"),
            )
            return MealPromptResponse(prompt=random.choice(_FALLBACK_PROMPTS))

        logger.info("Gemini'den meal prompt üretildi (güvenlik onaylı): %s", prompt)
        return MealPromptResponse(prompt=prompt)

    except Exception as e:
        logger.warning("Meal prompt üretimi başarısız, sabit listeye düşülüyor: %s", e)
        return MealPromptResponse(prompt=random.choice(_FALLBACK_PROMPTS))
