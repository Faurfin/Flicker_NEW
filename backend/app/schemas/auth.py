from pydantic import BaseModel
from typing import List, Optional
class PhoneRequest(BaseModel):
    phone_number: str

class VerifyRequest(BaseModel):
    phone_number: str
    code: str

class AuthResponse(BaseModel):
    access_token: str
    is_new_user: bool
    message: str

class ProfileUpdateRequest(BaseModel):
    phone_number: str
    name: str
    interests: List[str]
    discovery_source: str