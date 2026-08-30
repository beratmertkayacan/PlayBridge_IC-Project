import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.db import init_db
from app.routers import activity, ai_diagnostics, meal, screen_time, screen_to_play

# INFO seviyesindeki log'ların (örn. "Gemini'den gerçek aktivite üretildi")
# terminalde görünmesi için. Önceden varsayılan seviye WARNING'di, bu
# yüzden başarı log'ları hiç görünmüyordu. Sadece hatalar görünüyordu.
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger("playbridge")


@asynccontextmanager
async def lifespan(_app: FastAPI):
    try:
        init_db()
        logger.info("Postgres bağlantısı kuruldu, activity_logs tablosu hazır.")
    except Exception as exc:
        logger.warning(
            "Postgres ayağa kalkamadı. Aktivite üretimi çalışır, "
            "ekran süresi kaydı çalışmaz: %s",
            exc,
        )
    yield


app = FastAPI(title="PlayBridge AI Backend", lifespan=lifespan)

app.include_router(activity.router)
app.include_router(ai_diagnostics.router)
app.include_router(meal.router)
app.include_router(screen_to_play.router)
app.include_router(screen_time.router)


@app.get("/health")
def health_check():
    return {"status": "ok"}
