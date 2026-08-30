import logging

from fastapi import FastAPI

from app.routers import activity, ai_diagnostics, meal, screen_to_play

# INFO seviyesindeki log'ların (örn. "Gemini'den gerçek aktivite üretildi")
# terminalde görünmesi için. Önceden varsayılan seviye WARNING'di, bu
# yüzden başarı log'ları hiç görünmüyordu — sadece hatalar görünüyordu.
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

app = FastAPI(title="PlayBridge AI Backend")

app.include_router(activity.router)
app.include_router(ai_diagnostics.router)
app.include_router(meal.router)
app.include_router(screen_to_play.router)


@app.get("/health")
def health_check():
    return {"status": "ok"}
