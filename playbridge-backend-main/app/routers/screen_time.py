import logging
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.db import get_db
from app.models.activity_log import ActivityLog
from app.models.schemas import ScreenTimeLogRequest, ScreenTimeLogResponse, ScreenTimeWeekResponse

logger = logging.getLogger("playbridge.screen_time")

router = APIRouter(prefix="/api/v1/screen-time", tags=["screen-time"])


def _start_of_current_week_utc() -> datetime:
    now = datetime.now(timezone.utc)
    monday = now - timedelta(days=now.weekday())
    return monday.replace(hour=0, minute=0, second=0, microsecond=0)


@router.post("/log", response_model=ScreenTimeLogResponse)
def log_saved_minutes(
    payload: ScreenTimeLogRequest,
    db: Session = Depends(get_db),
) -> ScreenTimeLogResponse:
    if payload.saved_minutes < 1 or payload.saved_minutes > 180:
        raise HTTPException(
            status_code=400,
            detail="savedMinutes must be between 1 and 180.",
        )

    row = ActivityLog(
        saved_minutes=payload.saved_minutes,
        session_id=payload.session_id,
    )
    db.add(row)
    db.commit()
    db.refresh(row)

    logger.info(
        "Ekrandan kurtarılan %s dakika kaydedildi (id=%s, oturum=%s)",
        row.saved_minutes,
        row.id,
        row.session_id or "yok",
    )
    return ScreenTimeLogResponse(
        id=row.id,
        saved_minutes=row.saved_minutes,
        created_at=row.created_at,
        session_id=row.session_id,
    )


@router.get("/this-week", response_model=ScreenTimeWeekResponse)
def saved_minutes_this_week(
    session_id: str | None = Query(default=None, alias="sessionId"),
    db: Session = Depends(get_db),
) -> ScreenTimeWeekResponse:
    """
    Bu haftanın toplamı.

    `sessionId` verilirse yalnızca o oturumun kayıtları toplanıyor.
    Uygulamada "oturumu sonlandır" dendiğinde yeni bir kimlik üretiliyor,
    dolayısıyla sayaç doğal olarak sıfırdan başlıyor — sunucudaki hiçbir
    kayıt silinmeden. Kimlik verilmezse eski davranış korunuyor ve tüm
    kayıtlar toplanıyor.
    """
    start = _start_of_current_week_utc()
    query = select(func.coalesce(func.sum(ActivityLog.saved_minutes), 0)).where(
        ActivityLog.created_at >= start
    )
    if session_id:
        query = query.where(ActivityLog.session_id == session_id)

    minutes = int(db.scalar(query) or 0)
    logger.info(
        "Bu hafta ekrandan kurtarılan toplam: %s dakika (oturum=%s)",
        minutes,
        session_id or "tümü",
    )
    return ScreenTimeWeekResponse(saved_minutes_this_week=minutes)
