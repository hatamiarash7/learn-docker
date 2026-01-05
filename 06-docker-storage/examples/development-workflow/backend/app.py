"""
Development Workflow - Flask API
================================
This API demonstrates live reloading with bind mounts.
Edit this file and Flask will automatically reload!
"""

import os
from datetime import datetime

from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/api/hello")
def hello():
    """
    Simple hello endpoint.
    Try modifying the message and see it update without rebuilding!
    """
    return jsonify(
        {
            "message": "Hello from Flask API!",
            "timestamp": datetime.now().isoformat(),
            "version": "1.0.0",
            "tip": "Edit backend/app.py to change this response!",
        }
    )


@app.route("/api/health")
def health():
    """Health check endpoint."""
    return jsonify(
        {
            "status": "healthy",
            "service": "flask-api",
            "timestamp": datetime.now().isoformat(),
        }
    )


@app.route("/api/info")
def info():
    """System information endpoint."""
    return jsonify(
        {
            "python_version": os.popen("python --version").read().strip(),
            "flask_debug": os.environ.get("FLASK_DEBUG", "not set"),
            "database_url": os.environ.get("DATABASE_URL", "not set"),
            "working_directory": os.getcwd(),
        }
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
