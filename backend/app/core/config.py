import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DB_HOST: str = os.getenv("DB_HOST", "127.0.0.1")
    REDIS_HOST: str = os.getenv("REDIS_HOST", "127.0.0.1")
    

    DB_USER: str = "backend_user" 
    DB_PASS: str = "backend_password"
    DB_NAME: str = "backend_db"

    @property
    def DATABASE_URL(self) -> str:
        return f"postgresql+asyncpg://{self.DB_USER}:{self.DB_PASS}@{self.DB_HOST}:5432/{self.DB_NAME}"

    @property
    def REDIS_URL(self) -> str:
        return f"redis://{self.REDIS_HOST}:6379/0"

settings = Settings()