from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from models.db_schema import Review as ReviewModel
from schemas.review import ReviewCreate, ReviewOut
from database.db import get_db
from routes.auth import get_current_user
from utils.check_role import check_role
from datetime import datetime

router = APIRouter()
db_dependency = Depends(get_db)
user_dependency = Depends(get_current_user)

@router.get("/", response_model=List[ReviewOut])
async def get_reviews(db: Session = db_dependency, user: dict = user_dependency):
    return db.query(ReviewModel).all()

@router.post("/", response_model=ReviewOut, status_code=status.HTTP_201_CREATED)
async def create_review(review: ReviewCreate, db: Session = db_dependency, user: dict = user_dependency):
    new_review = ReviewModel(
        book_id=review.book_id,
        user_id=review.user_id,
        rating=review.rating,
        comment=review.comment,
        created_at=datetime.now()
    )
    db.add(new_review)
    db.commit()
    db.refresh(new_review)
    return new_review
