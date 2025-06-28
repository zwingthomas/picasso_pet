from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
from ..config import settings

sg = SendGridAPIClient(settings.sendgrid_api_key)


def send_order_confirmation(order):
    msg = Mail(
        from_email="no-reply@petscreamshop.com",
        to_emails=order.user_email,
        subject="Your Pet Scream Shop Order Confirmation",
        html_content="<p>Thanks for your order! We'll notify you when it ships.</p>"
    )
    sg.send(msg)

# stub: implement after tracking
 def send_shipping_notification(order):
    msg = Mail(
        from_email="no-reply@petscreamshop.com",
        to_emails=order.user_email,
        subject="Your order has shipped!",
        html_content=f"<p>Your tracking number: {order.tracking_number}</p>"
    )
    sg.send(msg)