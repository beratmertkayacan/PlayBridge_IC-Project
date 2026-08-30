import os

from dotenv import load_dotenv

load_dotenv()

GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")

# docker-compose.yml ile ayağa kalkan yerel Postgres.
# Farklı bir kurulumun varsa .env içinde DATABASE_URL'i değiştirmen yeterli.
DATABASE_URL = os.environ.get(
    "DATABASE_URL",
    "postgresql+psycopg2://playbridge:playbridge@127.0.0.1:5432/playbridge",
)

# Ücretsiz katmanda kota PROJE ve MODEL başına ayrı sayılıyor
# (GenerateRequestsPerDayPerProjectPerModel-FreeTier). Bu yüzden model
# adı koda gömülü değil, .env'den geliyor: kota dolduğunda tek satır
# değiştirip sunucuyu yeniden başlatmak yetiyor.
#
# Üretim ve güvenlik incelemesi BİLEREK farklı modeller: her aktivite
# iki çağrı yapıyor ve bu ikisi ayrı kotalardan yediği için günlük
# kapasite pratikte ikiye katlanıyor.
GEMINI_MODEL = os.environ.get("GEMINI_MODEL", "gemini-3.5-flash")
GEMINI_REVIEW_MODEL = os.environ.get("GEMINI_REVIEW_MODEL", "gemini-3.5-flash-lite")
