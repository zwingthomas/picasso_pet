from pydantic import BaseModel, EmailStr
from typing import Optional, List, Dict


class PetImageCreate(BaseModel):
    user_email: EmailStr


class PetImage(BaseModel):
    id: int
    user_email: EmailStr
    orig_key: str
    processed_key: Optional[str]
    status: str
    created_at: str

    class Config:
        orm_mode = True


class Product(BaseModel):
    id: int
    name: str
    sku: str
    price_cents: int
    variants: Dict

    class Config:
        orm_mode = True


class OrderItemCreate(BaseModel):
    product_id: int
    quantity: int
    pet_image_id: int


class OrderCreate(BaseModel):
    user_email: EmailStr
    items: List[OrderItemCreate]


class Order(BaseModel):
    id: int
    user_email: EmailStr
    stripe_session_id: str
    status: str
    total_cents: int
    created_at: str
    shipped_at: Optional[str]
    tracking_number: Optional[str]

    class Config:
        orm_mode = True


class CheckoutSession(BaseModel):
    url: str
