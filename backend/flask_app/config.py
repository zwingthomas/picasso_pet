import os
from dotenv import load_dotenv

load_dotenv()

# URL of your FastAPI service
API_URL = os.getenv('API_URL', 'http://localhost:8000/api')
