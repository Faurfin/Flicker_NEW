import base64
import os
import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db
from app.schemas.auth import PhoneRequest, VerifyRequest, AuthResponse, ProfileUpdateRequest
from app.services.auth_service import send_sms_logic, verify_code_and_login, update_user_profile

router = APIRouter(prefix="/auth", tags=["Авторизация"])

@router.post("/send-code")
async def send_code(request: PhoneRequest):
    await send_sms_logic(request.phone_number)
    return {"message": "Код отправлен"}

@router.post("/verify-code", response_model=AuthResponse)
async def verify_code(request: VerifyRequest, db: AsyncSession = Depends(get_db)):
    token, is_new, msg = await verify_code_and_login(db, request.phone_number, request.code)
    
    if not token:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=msg)
        
    return AuthResponse(access_token=token, is_new_user=is_new, message=msg)

@router.post("/update-profile")
async def update_profile(request: ProfileUpdateRequest, db: AsyncSession = Depends(get_db)):
    avatar_path = None
    
    # Если пришла аватарка, декодируем ее и сохраняем как файл
    if request.avatar_base64:
        try:
            img_data = base64.b64decode(request.avatar_base64)
            filename = f"{uuid.uuid4().hex}.jpg"
            save_dir = "static/avatars"
            os.makedirs(save_dir, exist_ok=True)
            
            filepath = os.path.join(save_dir, filename)
            with open(filepath, "wb") as f:
                f.write(img_data)
                
            avatar_path = f"/{filepath}"
        except Exception:
            raise HTTPException(status_code=400, detail="Неверный формат изображения")

    # Передаем данные в сервис (включая путь до сохраненной картинки)
    success = await update_user_profile(
        db=db, 
        phone_number=request.phone_number, 
        name=request.name, 
        interests=request.interests, 
        discovery_source=request.discovery_source,
        avatar_url=avatar_path  # Добавили новый параметр
    )
    
    if success:
        return {
            "message": "Профиль успешно заполнен", 
            "avatar_url": avatar_path
        }
        
    raise HTTPException(status_code=404, detail="Пользователь не найден")