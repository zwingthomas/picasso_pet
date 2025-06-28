import os
from celery import Celery
from celery.utils.log import get_task_logger
from PIL import Image
from google.cloud import storage
from database import SessionLocal
import crud
from config import settings

# Initialize Celery
celery = Celery('worker')
celery.config_from_object('celeryconfig')
logger = get_task_logger(__name__)

# Constants for compositing
# Ensure you package or mount 'assets/the_scream.jpg' into the container
BACKGROUND_PATH = os.getenv('BACKGROUND_PATH', 'assets/the_scream.jpg')
OUTPUT_PREFIX = 'processed/'


@celery.task(name='tasks.process_image')
def process_image(pet_id: int, orig_key: str):
    """
    Download original pet image from GCS, composite onto The Scream,
    upload processed image, and update DB record.
    """
    # Setup DB session and GCS client
    db = SessionLocal()
    client = storage.Client()
    bucket = client.bucket(settings.gcs_bucket_name)

    try:
        # Download original image
        orig_blob = bucket.blob(orig_key)
        local_orig = f"/tmp/{os.path.basename(orig_key)}"
        orig_blob.download_to_filename(local_orig)

        # Open images
        bg = Image.open(BACKGROUND_PATH).convert('RGBA')
        pet = Image.open(local_orig).convert('RGBA')

        # Resize pet to fit (example: width=300px, auto height)
        max_width = 300
        w_percent = (max_width / float(pet.size[0]))
        h_size = int((float(pet.size[1]) * float(w_percent)))
        pet = pet.resize((max_width, h_size), Image.ANTIALIAS)

        # Composite at fixed coords (e.g., x=200, y=150)
        position = (200, 150)
        bg.paste(pet, position, pet)

        # Save locally
        processed_local = f"/tmp/processed_{pet_id}.png"
        bg.save(processed_local, format='PNG')

        # Upload processed image
        processed_key = f"{OUTPUT_PREFIX}{pet_id}.png"
        proc_blob = bucket.blob(processed_key)
        proc_blob.upload_from_filename(
            processed_local, content_type='image/png')

        # Update database record
        crud.update_pet_image(
            db,
            crud.get_pet_image(db, pet_id),
            processed_key=processed_key,
            status='complete'
        )
        logger.info(f"Processed image {pet_id} successfully.")

    except Exception as e:
        logger.error(f"Failed processing image {pet_id}: {e}")
        # Mark as failed
        img = crud.get_pet_image(db, pet_id)
        crud.update_pet_image(db, img, status='failed')

    finally:
        db.close()
