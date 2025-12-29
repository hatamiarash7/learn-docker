"""
Simple Flask Application for Docker Learning
"""

import os
from datetime import datetime

from flask import Flask, jsonify

# Create Flask application
app = Flask(__name__)

# Get configuration from environment variables
APP_NAME = os.environ.get("APP_NAME", "Docker Flask App")
APP_VERSION = os.environ.get("APP_VERSION", "1.0.0")


@app.route("/")
def home():
    """Home page - returns HTML"""
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>{APP_NAME}</title>
        <style>
            body {{
                font-family: Arial, sans-serif;
                max-width: 800px;
                margin: 50px auto;
                padding: 20px;
                background: #f5f5f5;
            }}
            .container {{
                background: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }}
            h1 {{ color: #0db7ed; }}
            code {{
                background: #e9ecef;
                padding: 2px 8px;
                border-radius: 4px;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🐳 {APP_NAME}</h1>
            <p>Welcome! This Flask app is running inside a Docker container.</p>
            <h2>Available Endpoints:</h2>
            <ul>
                <li><code>GET /</code> - This page</li>
                <li><code>GET /health</code> - Health check</li>
                <li><code>GET /api/info</code> - Application info (JSON)</li>
            </ul>
            <h2>Environment:</h2>
            <ul>
                <li>Version: {APP_VERSION}</li>
                <li>Time: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}</li>
            </ul>
        </div>
    </body>
    </html>
    """


@app.route("/health")
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "timestamp": datetime.now().isoformat()})


@app.route("/api/info")
def info():
    """API info endpoint - returns JSON"""
    return jsonify(
        {
            "app_name": APP_NAME,
            "version": APP_VERSION,
            "python_version": os.popen("python --version").read().strip(),
            "timestamp": datetime.now().isoformat(),
            "endpoints": ["/", "/health", "/api/info"],
        }
    )


if __name__ == "__main__":
    # Run the Flask development server
    # host='0.0.0.0' makes it accessible from outside the container
    app.run(host="0.0.0.0", port=5000, debug=False)
