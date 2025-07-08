from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class ReviewCreate(BaseModel):
    book_id: int
    user_id: int
    rating: int
    comment: Optional[str] = None

class ReviewOut(ReviewCreate):
    id: int
    created_at: datetime
    user_name: Optional[str] = None
    book_title: Optional[str] = None

    class Config:
        from_attributes = True
