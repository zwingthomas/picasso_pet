FROM python:3.10-slim
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY . .

# On start, run migrations then start Uvicorn
CMD ["/bin/sh", "-c", "alembic upgrade head && uvicorn mai