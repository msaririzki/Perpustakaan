from database.db import Base
from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Boolean, Text
from sqlalchemy.orm import relationship
from datetime import datetime
  
class Users(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True)
    hashed_password = Column(String)
    role = Column(String) # 'admin' atau 'user'
    is_active = Column(Boolean, default=True, nullable=False)
    full_name = Column(String, nullable=True)
    email = Column(String, unique=True, nullable=True)
    # Relasi ke peminjaman dan review
    loans = relationship("Loan", back_populates="user")
    reviews = relationship("Review", back_populates="user")

class Category(Base):
    __tablename__ = 'categories'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)
    description = Column(String, nullable=True)
    books = relationship("Book", back_populates="category")

class Author(Base):
    __tablename__ = 'authors'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)
    bio = Column(Text, nullable=True)
    books = relationship("Book", back_populates="author")

class Book(Base):
    __tablename__ = 'books'
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, unique=True, nullable=False)
    description = Column(Text, nullable=True)
    stock = Column(Integer, default=0)
    cover_image = Column(String, nullable=True) # path/URL gambar sampul
    category_id = Column(Integer, ForeignKey("categories.id"))
    author_id = Column(Integer, ForeignKey("authors.id"))
    category = relationship("Category", back_populates="books")
    author = relationship("Author", back_populates="books")
    loans = relationship("Loan", back_populates="book")
    reviews = relationship("Review", back_populates="book")

class Loan(Base):
    __tablename__ = 'loans'
    id = Column(Integer, primary_key=True, index=True)
    book_id = Column(Integer, ForeignKey("books.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    loan_date = Column(DateTime, default=datetime.now)
    return_date = Column(DateTime, nullable=True)
    is_returned = Column(Boolean, default=False)
    book = relationship("Book", back_populates="loans")
    user = relationship("Users", back_populates="loans")

class Review(Base):
    __tablename__ = 'reviews'
    id = Column(Integer, primary_key=True, index=True)
    book_id = Column(Integer, ForeignKey("books.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    rating = Column(Integer, nullable=False) # 1-5
    comment = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.now)
    book = relationship("Book", back_populates="reviews")
    user = relationship("Users", back_populates="reviews")