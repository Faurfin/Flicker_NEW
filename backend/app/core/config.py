import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Если мы запускаем базы локально, то хост — localhost. 
    # Если внутри Docker-сети, то хостом для БД станет имя сервиса (db или redis).
    DB_HOST: str = os.getenv("DB_HOST", "localhost")
    REDIS_HOST: str = os.getenv("REDIS_HOST", "localhost")
    
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