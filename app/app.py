
import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/")
def home():
    return jsonify({
        "application": "Progress Partners Assessment App",
        "status": "running",
        "environment": os.getenv("APP_ENV", "local")
    })

@app.get("/hello")
def hello():
    return jsonify({"message": "Hello, Progress Partners!"}), 200

@app.get("/health")
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
