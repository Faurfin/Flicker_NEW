from pydantic import BaseModel
from typing import Literal, Optional


class RecommendedUser(BaseModel):
    id: str
    username: str
    subtitle: str
    avatar: str


class HideUserRequest(BaseModel):
    hidden_user_id: int


class UserProfileDetailResponse(BaseModel):
    id: int
    username: str
    avatar_url: Optional[str] = None
    bio: str
    friends_count: int
    friendship_status: Literal["none", "request_sent", "friends", "self"]