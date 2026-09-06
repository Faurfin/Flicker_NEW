from pydantic import BaseModel
from typing import Optional

class RecommendedUser(BaseModel):
    id: str
    username: str
    subtitle: str
    avatar: str

class HideUserRequest(BaseModel):
    hidden_user_id: int