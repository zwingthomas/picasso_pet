from sqlalchemy.orm import Session
from . import models, schemas

# PetImage CRUD


def create_pet_image(db: Session, user_email: str, orig_key: str):
    obj = models.PetImage(user_email=user_email, orig_key=orig_key)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj


def get_pet_image(db: Session, image_id: int):
    return db.query(models.PetImage).filter(models.PetImage.id == image_id).first()


def update_pet_image(db: Session, image: models.PetImage, **kwargs):
    for k, v in kwargs.items():
        setattr(image, k, v)
    db.commit()
    db.refresh(image)
    return image

# Product CRUD


def get_products(db: Session):
    return db.query(models.Product).all()


def get_product(db: Session, product_id: int):
    return db.query(models.Product).filter(models.Product.id == product_id).first()

# Order CRUD


def create_order(db: Session, order: schemas.OrderCreate, stripe_session_id: str, total_cents: int):
    db_order = models.Order(user_email=order.user_email,
                            stripe_session_id=stripe_session_id, total_cents=total_cents)
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    for itm in order.items:
        db_item = models.OrderItem(
            order_id=db_order.id,
            product_id=itm.product_id,
            pet_image_id=itm.pet_image_id,
            quantity=itm.quantity
        )
        db.add(db_item)
    db.commit()
    return db_order


def update_order_status(db: Session, session_id: str, status: str):
    order = db.query(models.Order).filter(
        models.Order.stripe_session_id == session_id).first()
    if order:
        order.status = status
        db.commit()
    return order
