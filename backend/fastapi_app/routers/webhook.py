from fastapi import APIRouter, Request, HTTPException, BackgroundTasks, Depends
from sqlalchemy.orm import Session
import stripe
from .. import crud, database, config, utils

router = APIRouter()
stripe.api_key = config.settings.stripe_api_key


@router.post("/webhook")
async def stripe_webhook(
    request: Request,
    background_tasks: BackgroundTasks,
    db: Session = Depends(database.SessionLocal)
):
    payload = await request.body()
    sig = request.headers.get("stripe-signature")
    try:
        event = stripe.Webhook.construct_event(
            payload, sig, config.settings.stripe_webhook_secret
        )
    except ValueError:
        raise HTTPException(400, "Invalid payload")
    except stripe.error.SignatureVerificationError:
        raise HTTPException(400, "Invalid signature")

    if event["type"] == "checkout.session.completed":
        sess = event["data"]["object"]
        order = crud.update_order_status(db, sess["id"], "paid")
        background_tasks.add_task(utils.send_order_confirmation, order)
        background_tasks.add_task(utils.call_printful_order, order)

    return {"status": "ok"}
