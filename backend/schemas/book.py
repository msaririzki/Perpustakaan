from pydantic import BaseModel
from typing import Optional

class BookCreate(BaseModel):
    title: str
    description: Optional[str] = None
    stock: int
    cover_image: Optional[str] = None
    category_id: int
    author_id: int

class BookOut(BookCreate):
    id: int
    category_name: Optional[str] = None
    author_name: Optional[str] = None

    class Config:
        from_attributes = True
