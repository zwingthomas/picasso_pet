FROM python:3.10-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy worker code and shared modules
COPY . .

# Environment variables for Celery and GCP credentials
ENV CELERY_BROKER_URL=${CELERY_BROKER_URL}
ENV GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS}

# Start Celery worker
CMD ["celery", "-A", "tasks", "worker", "--loglevel=info"]