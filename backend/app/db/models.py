from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.sql import func
from app.db.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    phone_number = Column(String, unique=True, index=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Поля профиля:
    name = Column(String, nullable=True)
    bio = Column(String, nullable=True)
    avatar_url = Column(String, nullable=True)
    interests = Column(ARRAY(String), nullable=True)
    discovery_source = Column(String, nullable=True)


class HiddenRecommendation(Base):
    __tablename__ = "hidden_recommendations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    hidden_user_id = Column(Integer, ForeignKey("users.id"))


class Friendship(Base):
    __tablename__ = "friendships"

    id = Column(Integer, primary_key=True, index=True)
    requester_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    addressee_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    # Статусы в БД: 'pending' (заявка отправлена) | 'accepted' (в друзьях)
    status = Column(String, nullable=False, default="pending")
    created_at = Column(DateTime(timezone=True), server_default=func.now())