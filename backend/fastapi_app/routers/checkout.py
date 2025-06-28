from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import stripe
from .. import crud, schemas, database, config

router = APIRouter()
stripe.api_key = config.settings.stripe_api_key


@router.post("/create-checkout", response_model=schemas.CheckoutSession)
def create_checkout(
    order: schemas.OrderCreate,
    db: Session = Depends(database.SessionLocal)
):
    # Build line items & calculate total
    line_items = []
    total = 0
    for itm in order.items:
        prod = crud.get_product(db, itm.product_id)
        if not prod:
            raise HTTPException(404, "Product not found")
        line_items.append({
            "price_data": {
                "currency": "usd",
                "product_data": {"name": prod.name},
                "unit_amount": prod.price_cents
            },
            "quantity": itm.quantity
        })
        total += prod.price_cents * itm.quantity

    session = stripe.checkout.Session.create(
        payment_method_types=["card"],
        line_items=line_items,
        mode="payment",
        success_url="https://your-domain.com/success?session_id={CHECKOUT_SESSION_ID}",
        cancel_url="https://your-domain.com/cancel"
    )

    crud.create_order(db, order, session.id, total)
    return schemas.CheckoutSession(url=session.url)
