import logging
import random

from fastapi import APIRouter, HTTPException

from app.models.schemas import MealPromptRequest, MealPromptResponse
from app.prompts.meal_prompt_generator import generate_meal_prompt
from app.prompts.safety_reviewer import review_text

logger = logging.getLogger("playbridge.meal")

router = APIRouter(prefix="/api/v1/meal", tags=["meal"])

# Bu liste artık YALNIZCA API'yi doğrudan kullananlar için (örn. Swagger
# UI'dan deneyenler). iOS istemcisi buraya düşmüyor — aşağıdaki nota bakın.
_FALLBACK_PROMPTS = [
    "Can you find three red things on the table?",
    "If your fork could talk, what would it say?",
    "Let's make up a three-word story together. You start!",
]


@router.post("/prompt", response_model=MealPromptResponse)
async def get_meal_prompt(request: MealPromptRequest) -> MealPromptResponse:
    """
    Yaşa ve konuya uygun tek cümlelik bir sohbet açıcı üretir.

    Yedekleme stratejisi neden değişti? Eskiden üretim çökerse burada
    duran 3 cümleden biri 200 ile dönüyordu. Ama iOS istemcisi artık
    kendi içinde 80 soruluk, YAŞ KADEMESİNE ve KONUYA duyarlı bir havuz
    taşıyor — yani istemcinin yedeği sunucunun yedeğinden çok daha iyi.

    Sunucu 200 ile zayıf bir cümle döndürdüğünde istemci bunu başarı
    sayıyor ve kendi zengin havuzunu hiç kullanmıyordu. Bu yüzden üretim
    başarısız olduğunda artık 503 dönüyoruz: istemci sessizce kendi
    havuzuna düşüyor, kullanıcı yine hiçbir hata ekranı görmüyor —
    sadece daha iyi bir soru görüyor.

    Kotanın dolduğu (429) bir günde fark tam olarak burada ortaya çıkıyor.
    """
    try:
        prompt = await generate_meal_prompt(request.age_range, request.category)
        review = await review_text(prompt)

        if not review.get("safe", True):
            logger.warning(
                "Meal prompt güvenlik incelemesinden geçemedi: %s", review.get("issues")
            )
            raise HTTPException(
                status_code=503,
                detail="Generated prompt did not pass the safety review.",
            )

        logger.info(
            "Gemini'den meal prompt üretildi (konu=%s, güvenlik onaylı): %s",
            request.category or "serbest",
            prompt,
        )
        return MealPromptResponse(prompt=prompt)

    except HTTPException:
        raise
    except Exception as e:
        logger.warning(
            "Meal prompt üretimi başarısız, istemci kendi havuzuna düşecek: %s", e
        )
        raise HTTPException(
            status_code=503,
            detail=f"Meal prompt generation is unavailable: {e}",
        ) from e


@router.get("/prompt/fallback", response_model=MealPromptResponse)
def get_fallback_prompt() -> MealPromptResponse:
    """
    Elle yazılmış güvenli bir cümle. Yalnızca API'yi doğrudan denemek
    isteyenler için (Swagger UI); uygulamanın akışının parçası değil.
    """
    return MealPromptResponse(prompt=random.choice(_FALLBACK_PROMPTS))
