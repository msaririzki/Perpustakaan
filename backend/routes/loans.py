from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from models.db_schema import Loan as LoanModel, Book as BookModel, Users as UserModel
from schemas.loan import LoanCreate, LoanOut
from database.db import get_db
from routes.auth import get_current_user
from utils.check_role import check_role
from datetime import datetime

router = APIRouter()
db_dependency = Depends(get_db)
user_dependency = Depends(get_current_user)

@router.get("/", response_model=List[LoanOut])
async def get_loans(db: Session = db_dependency, user: dict = user_dependency):
    loans = db.query(LoanModel).all()
    return loans

@router.post("/", response_model=LoanOut, status_code=status.HTTP_201_CREATED)
async def create_loan(loan: LoanCreate, db: Session = db_dependency, user: dict = user_dependency):
    # Cek stok buku
    book = db.query(BookModel).filter(BookModel.id == loan.book_id).first()
    if not book or book.stock < 1:
        raise HTTPException(status_code=400, detail="Book not available")
    # Kurangi stok buku
    book.stock -= 1
    new_loan = LoanModel(
        book_id=loan.book_id,
        user_id=loan.user_id,
        loan_date=loan.loan_date or datetime.now(),
        is_returned=False
    )
    db.add(new_loan)
    db.commit()
    db.refresh(new_loan)
    return new_loan

@router.put("/{loan_id}/return", response_model=LoanOut)
async def return_loan(loan_id: int, db: Session = db_dependency, user: dict = user_dependency):
    loan = db.query(LoanModel).filter(LoanModel.id == loan_id).first()
    if not loan or loan.is_returned:
        raise HTTPException(status_code=404, detail="Loan not found or already returned")
    loan.is_returned = True
    loan.return_date = datetime.now()
    # Tambah stok buku
    book = db.query(BookModel).filter(BookModel.id == loan.book_id).first()
    if book:
        book.stock += 1
    db.commit()
    db.refresh(loan)
    return loan
