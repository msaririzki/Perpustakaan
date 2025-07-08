from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class LoanCreate(BaseModel):
    book_id: int
    user_id: int
    loan_date: Optional[datetime] = None
    return_date: Optional[datetime] = None
    is_returned: Optional[bool] = False

class LoanOut(LoanCreate):
    id: int
    book_title: Optional[str] = None
    user_name: Optional[str] = None

    class Config:
        from_attributes = True
