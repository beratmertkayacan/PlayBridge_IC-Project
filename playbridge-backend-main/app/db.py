from sqlalchemy import create_engine, text
from sqlalchemy.orm import DeclarativeBase, sessionmaker

from app.config import DATABASE_URL


class Base(DeclarativeBase):
    pass


engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db() -> None:
    """Tablolar yoksa oluşturur. Alembic yok: hackathon için yeterli."""
    from app.models.activity_log import ActivityLog  # noqa: F401

    Base.metadata.create_all(bind=engine)

    # create_all yalnızca EKSİK TABLOYU yaratır, var olan bir tabloya
    # yeni kolon EKLEMEZ. session_id sonradan eklendiği için, daha önce
    # oluşturulmuş bir veritabanında elle eklenmesi gerekiyor.
    # IF NOT EXISTS sayesinde her açılışta güvenle çalışabiliyor.
    with engine.begin() as connection:
        connection.execute(
            text("ALTER TABLE activity_logs ADD COLUMN IF NOT EXISTS session_id VARCHAR(64)")
        )
        connection.execute(
            text(
                "CREATE INDEX IF NOT EXISTS ix_activity_logs_session_id "
                "ON activity_logs (session_id)"
            )
        )
