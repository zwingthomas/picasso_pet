from fastapi import FastAPI
from . import models, database
from .routers import upload, checkout, webhook, admin

# Optional: create tables if not using Alembic
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(title="Pet Scream Shop API")

app.include_router(upload.router, prefix="/api", tags=["upload"])
app.include_router(checkout.router, prefix="/api", tags=["checkout"])
app.include_router(webhook.router, prefix="/api", tags=["webhook"])
app.include_router(admin.router, prefix="/api", tags=["admin"])
