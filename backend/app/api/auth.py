from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.database import get_db
from app.schemas.auth import PhoneRequest, VerifyRequest, AuthResponse
from app.services.auth_service import send_sms_logic, verify_code_and_login

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