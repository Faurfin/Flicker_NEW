from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, not_
from pydantic import BaseModel
from app.db.database import get_db
from app.db.models import User, HiddenRecommendation
from app.schemas.users import RecommendedUser, HideUserRequest

router = APIRouter(prefix="/users", tags=["Пользователи"])

@router.get("/recommendations", response_model=list[RecommendedUser])
async def get_recommendations(
    phone_number: str, 
    db: AsyncSession = Depends(get_db)
):
    # 1. Находим текущего пользователя (теперь плюс доходит корректно)
    user_query = await db.execute(select(User).where(User.phone_number == phone_number))
    current_user = user_query.scalars().first()
    
    if not current_user or not current_user.interests:
        return []

    # 2. Достаем черный список (крестики)
    hidden_query = await db.execute(
        select(HiddenRecommendation.hidden_user_id)
        .where(HiddenRecommendation.user_id == current_user.id)
    )
    hidden_ids = hidden_query.scalars().all()

    # 3. Ищем ВСЕХ пользователей с общими интересами (совпадение хотя бы 1 интереса)
    query = select(User).where(
        and_(
            User.id != current_user.id, 
            User.interests.overlap(current_user.interests) 
        )
    )

    if hidden_ids:
        query = query.where(not_(User.id.in_(hidden_ids)))

    # Ограничиваем выдачу ровно 5 людьми
    query = query.limit(5) 

    result = await db.execute(query)
    matching_users = result.scalars().all()

    # 4. Формируем список
    recommendations = []
    for u in matching_users:
        common = set(current_user.interests) & set(u.interests)
        common_str = ", ".join(list(common)[:2]) 
        
        avatar = u.avatar_url
        if avatar and not avatar.startswith("http"):
            avatar = f"http://127.0.0.1:8000/{avatar.lstrip('/')}"
        elif not avatar:
            avatar = "https://i.pravatar.cc/150" # Заглушка, если человек реально не загрузил фото 

        recommendations.append(
            RecommendedUser(
                id=str(u.id),
                username=u.name or "Пользователь",
                subtitle=f"Общие интересы: {common_str}",
                avatar=avatar
            )
        )

    return recommendations

@router.post("/hide-recommendation")
async def hide_recommendation(
    request: HideUserRequest, 
    phone_number: str, 
    db: AsyncSession = Depends(get_db)
):
    user_query = await db.execute(select(User).where(User.phone_number == phone_number))
    current_user = user_query.scalars().first()
    
    if not current_user:
        raise HTTPException(status_code=404)

    hidden_record = HiddenRecommendation(
        user_id=current_user.id,
        hidden_user_id=request.hidden_user_id
    )
    db.add(hidden_record)
    await db.commit()
    
    return {"message": "Пользователь навсегда скрыт"}


class UserProfile(BaseModel):
    id: str
    username: str
    avatar: str
    link: str

@router.get("/me", response_model=UserProfile)
async def get_my_profile(phone_number: str, db: AsyncSession = Depends(get_db)):
    user_query = await db.execute(select(User).where(User.phone_number == phone_number))
    current_user = user_query.scalars().first()
    
    if not current_user:
        raise HTTPException(status_code=404, detail="Пользователь не найден")

    # Формируем правильную ссылку на аватар
    avatar = current_user.avatar_url
    if avatar and not avatar.startswith("http"):
        avatar = f"http://127.0.0.1:8000/{avatar.lstrip('/')}"
    elif not avatar:
        avatar = "https://i.pravatar.cc/150"

    # Временная логика юзернейма, позже доработаем
    username = current_user.name or f"user_{current_user.id}"
    
    return UserProfile(
        id=str(current_user.id),
        username=username,
        avatar=avatar,
        link=f"fliker://app/profile/{username}"
    )