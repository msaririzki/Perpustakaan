from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from models.db_schema import Book as BookModel, Category as CategoryModel, Author as AuthorModel
from schemas.book import BookCreate, BookOut
from database.db import get_db
from routes.auth import get_current_user
from utils.check_role import check_role

router = APIRouter()
db_dependency = Depends(get_db)
user_dependency = Depends(get_current_user)

@router.get("/", response_model=List[BookOut])
async def get_books(db: Session = db_dependency, user: dict = user_dependency):
    books = db.query(
        BookModel.id,
        BookModel.title,
        BookModel.description,
        BookModel.stock,
        BookModel.cover_image,
        BookModel.category_id,
        BookModel.author_id,
        CategoryModel.name.label("category_name"),
        AuthorModel.name.label("author_name"),
    ).join(
        CategoryModel, BookModel.category_id == CategoryModel.id
    ).join(
        AuthorModel, BookModel.author_id == AuthorModel.id
    ).all()
    return books

@router.post("/", response_model=BookOut, status_code=status.HTTP_201_CREATED)
@check_role(["admin"])
async def create_book(book: BookCreate, db: Session = db_dependency, user: dict = user_dependency):
    new_book = BookModel(**book.model_dump())
    db.add(new_book)
    db.commit()
    db.refresh(new_book)
    return new_book

@router.get("/{book_id}", response_model=BookOut)
async def get_book(book_id: int, db: Session = db_dependency, user: dict = user_dependency):
    book = db.query(BookModel).filter(BookModel.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")
    return book

@router.put("/{book_id}", response_model=BookOut)
@check_role(["admin"])
async def update_book(book_id: int, book: BookCreate, db: Session = db_dependency, user: dict = user_dependency):
    db_book = db.query(BookModel).filter(BookModel.id == book_id).first()
    if not db_book:
        raise HTTPException(status_code=404, detail="Book not found")
    for key, value in book.model_dump().items():
        setattr(db_book, key, value)
    db.commit()
    db.refresh(db_book)
    return db_book

@router.delete("/{book_id}", status_code=status.HTTP_204_NO_CONTENT)
@check_role(["admin"])
async def delete_book(book_id: int, db: Session = db_dependency, user: dict = user_dependency):
    db_book = db.query(BookModel).filter(BookModel.id == book_id).first()
    if not db_book:
        raise HTTPException(status_code=404, detail="Book not found")
    db.delete(db_book)
    db.commit()
    return None
