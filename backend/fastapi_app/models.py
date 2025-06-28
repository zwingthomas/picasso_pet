from sqlalchemy import Column, Integer, String, JSON, TIMESTAMP, ForeignKey
from sqlalchemy.sql import func
from .database import Base


class PetImage(Base):
    __tablename__ = "pet_images"
    id = Column(Integer, primary_key=True, index=True)
    user_email = Column(String, index=True)
    orig_key = Column(String, nullable=False)
    processed_key = Column(String)
    status = Column(String, default="pending")
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())


class Product(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    sku = Column(String, unique=True, index=True, nullable=False)
    price_cents = Column(Integer, nullable=False)
    variants = Column(JSON)


class Order(Base):
    __tablename__ = "orders"
    id = Column(Integer, primary_key=True, index=True)
    user_email = Column(String, index=True)
    stripe_session_id = Column(String, unique=True, index=True, nullable=False)
    status = Column(String, default="created")
    total_cents = Column(Integer, nullable=False)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    shipped_at = Column(TIMESTAMP(timezone=True))
    tracking_number = Column(String)


class OrderItem(Base):
    __tablename__ = "order_items"
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"))
    product_id = Column(Integer, ForeignKey("products.id"))
    pet_image_id = Column(Integer, ForeignKey("pet_images.id"))
    quantity = Column(Integer, nullable=False)
