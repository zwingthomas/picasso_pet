import os
from pydantic import BaseSettings


class Settings(BaseSettings):
    database_url: str
    stripe_api_key: str
    stripe_webhook_secret: str
    sendgrid_api_key: str
    printful_api_key: str
    gcs_bucket_name: str
    celery_broker_url: str

    class Config:
        env_file = ".env"


settings = Settings()
