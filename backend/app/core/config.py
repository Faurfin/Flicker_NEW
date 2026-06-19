from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Обновленная ссылка с новыми доступами: backend_user, backend_password и backend_db
    DATABASE_URL: str = "postgresql+asyncpg://backend_user:backend_password@localhost:5432/backend_db"
    REDIS_URL: str = "redis://localhost:6379/0"

settings = Settings()