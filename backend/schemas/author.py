from pydantic import BaseModel
from typing import Optional

class AuthorCreate(BaseModel):
    name: str
    bio: Optional[str] = None

class AuthorOut(AuthorCreate):
    id: int

    class Config:
        from_attributes = True
