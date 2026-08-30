from datetime import datetime, timezone

from sqlalchemy import DateTime, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db import Base


class ActivityLog(Base):
    __tablename__ = "activity_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    saved_minutes: Mapped[int] = mapped_column(Integer, nullable=False)

    # Hangi oturuma ait. Uygulama "oturumu sonlandır" dendiğinde yeni bir
    # kimlik üretiyor; eski kayıtlar SİLİNMİYOR, sadece artık sorgulanan
    # oturuma ait olmadıkları için toplamlara girmiyorlar.
    #
    # Nullable: bu kolon eklenmeden önce yazılmış kayıtlar var ve onları
    # kaybetmek istemiyoruz.
    session_id: Mapped[str | None] = mapped_column(
        String(64), nullable=True, index=True, default=None
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )
