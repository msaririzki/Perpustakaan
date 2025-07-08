from fastapi import FastAPI, status, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from models.enum_items import Role
from database.db import engine, get_db
from typing import Annotated
from sqlalchemy.orm import Session
from utils.check_role import check_role

import models.db_schema as db_schema
import routes.auth as auth
import routes.books as books
import routes.categories as categories
import routes.authors as authors
import routes.loans as loans
import routes.reviews as reviews
import routes.users as users

app = FastAPI()
app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(books.router, prefix="/books", tags=["Books"])
app.include_router(categories.router, prefix="/categories", tags=["Categories"])
app.include_router(authors.router, prefix="/authors", tags=["Authors"])
app.include_router(loans.router, prefix="/loans", tags=["Loans"])
app.include_router(reviews.router, prefix="/reviews", tags=["Reviews"])
app.include_router(users.router, prefix="/users", tags=["Users"])
app.add_middleware(
  CORSMiddleware,
  allow_origins=["*"],
  allow_credentials=True,
  allow_methods=["*"],
  allow_headers=["*"],
)

db_schema.Base.metadata.create_all(bind=engine)
    
db_dependency = Annotated[Session, Depends(get_db)]
user_dependency = Annotated[dict, Depends(auth.get_current_user)]

@app.get("/user", status_code=status.HTTP_200_OK)
async def get_current_user(user: user_dependency, db: db_dependency):
  if user is None:
    raise HTTPException(status_code=401, detail='Authentication failed')
  return {"User": user}

@app.get("/admin-route", status_code=status.HTTP_200_OK)
@check_role([Role.ADMIN])
async def admin_route(user: user_dependency, db: db_dependency):
  return {"message": "This is admin only route", "user": user}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)