from datetime import timedelta, datetime
from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from starlette import status
from models.db_schema import Users
from database.db import get_db
from schemas.user import Token, CreateUserRequest
from passlib.context import CryptContext
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from jose import jwt, JWTError
from models.enum_items import Role

router = APIRouter()

SECRET_KEY = 'supersecret'
ALGORITHM = 'HS256'

bcrypt_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
oauth2_bearer = OAuth2PasswordBearer(tokenUrl='auth/login')
    
db_dependency = Annotated[Session, Depends(get_db)]

# ===/auth routes===

@router.post("/register", status_code=status.HTTP_201_CREATED)
async def create_user(db: db_dependency, create_user_request: CreateUserRequest):
    if create_user_request.role is None:
        role = Role.GENERAL_USER.value
    else:
        role = create_user_request.role
    create_user_model = Users(
        username=create_user_request.username,
        hashed_password=bcrypt_context.hash(create_user_request.password),
        role=role,
        is_active=True,
        email=create_user_request.email,
        full_name=create_user_request.full_name
    )
    db.add(create_user_model)
    db.commit()
  
@router.post("/login", response_model=Token)
async def login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()], db: db_dependency):
  user = authenticate_user(form_data.username, form_data.password, db)
  if not user:
      raise HTTPException(
          status_code=status.HTTP_401_UNAUTHORIZED,
          detail='Could not validate user.'
      )
  
  # Check if user is active
  if not user.is_active:
      raise HTTPException(
          status_code=status.HTTP_401_UNAUTHORIZED,
          detail='Account is disabled.'
      )
  
  token = create_access_token(
      user.username,
      user.id,
      user.role,
      timedelta(minutes=20)
  )
  
  return {'access_token': token, 'token_type': 'bearer'}

# ===Helper functions===
  
def authenticate_user(username: str, password: str, db):
  user = db.query(Users).filter(Users.username == username).first()
  if not user:
    return False
  if not bcrypt_context.verify(password, user.hashed_password):
    return False
  return user

def create_access_token(username: str, user_id: int, role: str, expires_delta: timedelta):
  encode = {'sub': username, 'id': user_id, 'role': role}
  expires = datetime.now() + expires_delta
  encode.update({'exp': expires})
  return jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_current_user(
    token: Annotated[str, Depends(oauth2_bearer)],
    db: Annotated[Session, Depends(get_db)]
):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get('sub')
        user_id: int = payload.get('id')
        user_role: str = payload.get('role')
        
        if username is None or user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail='Could not validate user.'
            )
            
        # Get fresh user data from database
        user = db.query(Users).filter(Users.id == user_id).first()
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail='User not found.'
            )
            
        return {
            'username': username,
            'id': user_id,
            'role': user_role,
            'is_active': bool(user.is_active)  # Convert SQLite 0/1 to boolean
        }
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail='Could not validate user.'
        )