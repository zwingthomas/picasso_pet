import stripe
from ..config import settings

stripe.api_key = settings.stripe_api_key


def verify_webhook_event(payload: bytes, sig_header: str):
    return stripe.Webhook.construct_event(
        payload, sig_header, settings.stripe_webhook_secret
    )
