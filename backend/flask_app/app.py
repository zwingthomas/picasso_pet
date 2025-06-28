from flask import Flask, render_template
import requests
from config import API_URL

app = Flask(__name__)


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/catalog')
def catalog():
    # Fetch product list from FastAPI
    resp = requests.get(f"{API_URL}/products")
    resp.raise_for_status()
    products = resp.json()
    return render_template('catalog.html', products=products)


@app.route('/upload')
def upload():
    # Render upload page, passing API URL for JS
    return render_template('upload.html', api_url=API_URL)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
