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
