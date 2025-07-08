from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from models.db_schema import Author as AuthorModel
from schemas.author import AuthorCreate, AuthorOut
from database.db import get_db
from routes.auth import get_current_user
from utils.check_role import check_role

router = APIRouter()
db_dependency = Depends(get_db)
user_dependency = Depends(get_current_user)

@router.get("/", response_model=List[AuthorOut])
async def get_authors(db: Session = db_dependency, user: dict = user_dependency):
    return db.query(AuthorModel).all()

@router.post("/", response_model=AuthorOut, status_code=status.HTTP_201_CREATED)
@check_role(["admin"])
async def create_author(author: AuthorCreate, db: Session = db_dependency, user: dict = user_dependency):
    new_author = AuthorModel(**author.model_dump())
    db.add(new_author)
    db.commit()
    db.refresh(new_author)
    return new_author

@router.get("/{author_id}", response_model=AuthorOut)
async def get_author(author_id: int, db: Session = db_dependency, user: dict = user_dependency):
    author = db.query(AuthorModel).filter(AuthorModel.id == author_id).first()
    if not author:
        raise HTTPException(status_code=404, detail="Author not found")
    return author

@router.put("/{author_id}", response_model=AuthorOut)
@check_role(["admin"])
async def update_author(author_id: int, author: AuthorCreate, db: Session = db_dependency, user: dict = user_dependency):
    db_author = db.query(AuthorModel).filter(AuthorModel.id == author_id).first()
    if not db_author:
        raise HTTPException(status_code=404, detail="Author not found")
    for key, value in author.model_dump().items():
        setattr(db_author, key, value)
    db.commit()
    db.refresh(db_author)
    return db_author

@router.delete("/{author_id}", status_code=status.HTTP_204_NO_CONTENT)
@check_role(["admin"])
async def delete_author(author_id: int, db: Session = db_dependency, user: dict = user_dependency):
    db_author = db.query(AuthorModel).filter(AuthorModel.id == author_id).first()
    if not db_author:
        raise HTTPException(status_code=404, detail="Author not found")
    db.delete(db_author)
    db.commit()
    return None
