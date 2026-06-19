from pydantic import BaseModel

class PhoneRequest(BaseModel):
    phone_number: str

class VerifyRequest(BaseModel):
    phone_number: str
    code: str

class AuthResponse(BaseModel):
    access_token: str
    is_new_user: bool
    message: str