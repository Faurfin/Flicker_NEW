import random
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.db.database import redis_client
from app.db.models import User

async def send_sms_logic(phone_number: str):
    # Генерируем 5-значный код (от 10000 до 99999)
    code = str(random.randint(10000, 99999))
    
    # Сохраняем в Redis на 3 минуты (180 сек)
    await redis_client.setex(f"sms:{phone_number}", 180, code)
    
    print(f"\n[{phone_number}] ---> СМС КОД: {code}\n")
    return True

async def verify_code_and_login(db: AsyncSession, phone_number: str, code: str):
    # 1. Проверяем код в Redis
    saved_code = await redis_client.get(f"sms:{phone_number}")
    
    if not saved_code or saved_code != code:
        return None, False, "Неверный или просроченный код"
        
    # 2. Удаляем использованный код
    await redis_client.delete(f"sms:{phone_number}")
    
    # 3. Ищем пользователя в PostgreSQL
    result = await db.execute(select(User).where(User.phone_number == phone_number))
    user = result.scalars().first()
    
    is_new_user = False
    if not user:
        # 4. Если нет - создаем (Регистрация)
        user = User(phone_number=phone_number)
        db.add(user)
        await db.commit()
        await db.refresh(user)
        is_new_user = True
        
    # В будущем тут будет реальный генератор JWT токенов
    fake_jwt_token = f"token_for_user_{user.id}"
    
    return fake_jwt_token, is_new_user, "Успешно"