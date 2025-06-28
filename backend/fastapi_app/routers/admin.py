from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from .. import models, database

router = APIRouter()


@router.get("/orders")
def list_orders(skip: int = 0, limit: int = 100, db: Session = Depends(database.SessionLocal)):
    return db.query(models.Order).offset(skip).limit(limit).all()
