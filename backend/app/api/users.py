from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, not_, or_, func
from pydantic import BaseModel
from app.db.database import get_db
from app.db.models import User, HiddenRecommendation, Friendship
from app.schemas.users import (
    RecommendedUser,
    HideUserRequest,
    UserProfileDetailResponse,
)

router = APIRouter(prefix="/users", tags=["Пользователи"])

# ... существующие эндпоинты /recommendations, /hide-recommendation, /me, /search ...


@router.get("/{user_id}", response_model=UserProfileDetailResponse)
async def get_user_profile_by_id(
    user_id: int,
    phone_number: str = Query(None),
    db: AsyncSession = Depends(get_db),
):
    # 1. Ищем целевого пользователя по ID
    target_query = await db.execute(select(User).where(User.id == user_id))
    target_user = target_query.scalars().first()

    if not target_user:
        raise HTTPException(status_code=404, detail="Пользователь не найден")

    # 2. Считаем количество друзей (статус 'accepted' в таблице friendships)
    friends_count_query = await db.execute(
        select(func.count(Friendship.id)).where(
            and_(
                Friendship.status == "accepted",
                or_(
                    Friendship.requester_id == target_user.id,
                    Friendship.addressee_id == target_user.id,
                ),
            )
        )
    )
    friends_count = friends_count_query.scalar() or 0

    # 3. Определяем статус дружбы с текущим авторизованным пользователем
    friendship_status = "none"
    if phone_number:
        current_query = await db.execute(
            select(User).where(User.phone_number == phone_number)
        )
        current_user = current_query.scalars().first()

        if current_user:
            if current_user.id == target_user.id:
                friendship_status = "self"
            else:
                rel_query = await db.execute(
                    select(Friendship).where(
                        or_(
                            and_(
                                Friendship.requester_id == current_user.id,
                                Friendship.addressee_id == target_user.id,
                            ),
                            and_(
                                Friendship.requester_id == target_user.id,
                                Friendship.addressee_id == current_user.id,
                            ),
                        )
                    )
                )
                relation = rel_query.scalars().first()

                if relation:
                    if relation.status == "accepted":
                        friendship_status = "friends"
                    elif relation.status == "pending":
                        friendship_status = "request_sent"

    # 4. Формируем корректный URL аватара и описание профиля (bio)
    avatar_url = target_user.avatar_url
    if avatar_url and not avatar_url.startswith("http"):
        avatar_url = f"http://localhost:8000/{avatar_url.lstrip('/')}"

    if target_user.bio:
        bio_text = target_user.bio
    elif target_user.interests:
        bio_text = f"Интересы: {', '.join(target_user.interests)}"
    else:
        bio_text = "Пользователь пока ничего не рассказал о себе"

    username = target_user.name or f"user_{target_user.id}"

    return UserProfileDetailResponse(
        id=target_user.id,
        username=username,
        avatar_url=avatar_url,
        bio=bio_text,
        friends_count=friends_count,
        friendship_status=friendship_status,
    )