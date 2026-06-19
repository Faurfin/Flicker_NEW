from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.dialects.postgresql import ARRAY # Специальный тип для массивов в Postgres
from sqlalchemy.sql import func
from app.db.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    phone_number = Column(String, unique=True, index=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # НОВЫЕ ПОЛЯ ДЛЯ ПРОФИЛЯ:
    name = Column(String, nullable=True) # Имя пользователя
    avatar_url = Column(String, nullable=True) # Ссылка на аватарку
    interests = Column(ARRAY(String), nullable=True) # Массив интересов (например: ["CS2", "Футбол"])
    discovery_source = Column(String, nullable=True) # Как о нас узнали