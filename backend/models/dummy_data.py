import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


from sqlalchemy.orm import Session
from db_schema import Users, Category, Author, Book, Loan, Review
from datetime import datetime, timedelta
from passlib.hash import bcrypt
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

SQLALCHEMY_DATABASE_URL = 'sqlite:///database/app.db'
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={'check_same_thread': False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
db: Session = SessionLocal()

# Clear existing data (optional, for clean testing)
db.query(Review).delete()
db.query(Loan).delete()
db.query(Book).delete()
db.query(Author).delete()
db.query(Category).delete()
db.query(Users).delete()

db.commit()

# Users
dummy_users = [
    Users(username="admin", hashed_password=bcrypt.hash("admin123"), role="admin", is_active=True, full_name="Admin Perpus", email="admin@perpus.com"),
    Users(username="johndoe", hashed_password=bcrypt.hash("password"), role="user", is_active=True, full_name="John Doe", email="john@user.com")
]
db.add_all(dummy_users)
db.commit()

# Categories (Genre)
categories = [
    Category(name="Fiksi", description="Novel dan cerita fiksi"),
    Category(name="Non-Fiksi", description="Buku pengetahuan dan referensi"),
    Category(name="Komik", description="Komik dan manga")
]
db.add_all(categories)
db.commit()

# Authors
authors = [
    Author(name="Tere Liye", bio="Penulis novel populer Indonesia."),
    Author(name="J.K. Rowling", bio="Penulis serial Harry Potter."),
    Author(name="Eiichiro Oda", bio="Mangaka One Piece.")
]
db.add_all(authors)
db.commit()

# Books
books = [
    Book(title="Bumi", description="Novel petualangan fantasi.", stock=10, cover_image=None, category_id=1, author_id=1),
    Book(title="Harry Potter and the Sorcerer's Stone", description="Buku pertama Harry Potter.", stock=7, cover_image=None, category_id=1, author_id=2),
    Book(title="One Piece Vol. 1", description="Awal petualangan Luffy.", stock=15, cover_image=None, category_id=3, author_id=3)
]
db.add_all(books)
db.commit()

# Loans (Peminjaman)
loans = [
    Loan(book_id=1, user_id=2, loan_date=datetime.now() - timedelta(days=2), return_date=None, is_returned=False),
    Loan(book_id=2, user_id=2, loan_date=datetime.now() - timedelta(days=10), return_date=datetime.now() - timedelta(days=2), is_returned=True)
]
db.add_all(loans)
db.commit()

# Reviews (Ulasan)
reviews = [
    Review(book_id=1, user_id=2, rating=5, comment="Sangat seru dan inspiratif!", created_at=datetime.now() - timedelta(days=1)),
    Review(book_id=2, user_id=2, rating=4, comment="Ceritanya menarik, cocok untuk semua umur.", created_at=datetime.now() - timedelta(days=5))
]
db.add_all(reviews)
db.commit()

print("Dummy data perpustakaan berhasil dimasukkan.")
