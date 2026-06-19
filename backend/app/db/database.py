from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy.orm import declarative_base
import redis.asyncio as redis
from app.core.config import settings

# Настройка PostgreSQL
engine = create_async_engine(settings.DATABASE_URL, echo=True)
AsyncSessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
Base = declarative_base()

# Настройка Redis
redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)

# Зависимость для получения сессии БД в эндпоинтах
async def get_db():
    async with AsyncSessionLocal() as session:
        yield session