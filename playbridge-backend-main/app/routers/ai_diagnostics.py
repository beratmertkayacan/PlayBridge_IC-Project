from fastapi import APIRouter, HTTPException

from app.services.ai_client import ping

router = APIRouter(prefix="/api/v1/ai", tags=["ai-diagnostics"])


@router.get("/ping")
async def ai_ping():
    """
    Sadece geliştirme sırasında API anahtarının doğru çalıştığını
    hızlıca doğrulamak için. Uygulamanın gerçek akışının bir parçası
    değil — Swagger UI'dan (/docs) tek tıkla denenebilir.
    """
    try:
        reply = await ping()
        return {"connected": True, "model_reply": reply}
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"AI çağrısı başarısız: {e}")
