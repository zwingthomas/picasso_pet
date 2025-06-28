from fastapi import APIRouter, UploadFile, File, Form, Depends, HTTPException
from google.cloud import storage
from celery import Celery
from sqlalchemy.orm import Session
from .. import crud, schemas, database, config

router = APIRouter()
celery = Celery(__name__, broker=config.settings.celery_broker_url)


@router.post("/upload", response_model=schemas.PetImage)
async def upload_image(
    user_email: str = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(database.SessionLocal)
):
    # Upload raw image to GCS
    bucket = storage.Client().bucket(config.settings.gcs_bucket_name)
    blob = bucket.blob(f"orig/{file.filename}")
    content = await file.read()
    blob.upload_from_string(content, content_type=file.content_type)

    # Create DB record
    pet = crud.create_pet_image(db, user_email=user_email, orig_key=blob.name)

    # Enqueue processing task
    celery.send_task("tasks.process_image", args=[pet.id, blob.name])
    return pet
