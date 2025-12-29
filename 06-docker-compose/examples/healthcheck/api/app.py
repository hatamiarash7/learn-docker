"""
Simple API with health check endpoint
Demonstrates connectivity to database and cache
"""

import os
import time

import mysql.connector
import redis
from flask import Flask, jsonify

app = Flask(__name__)

# Configuration
DB_HOST = os.environ.get("DB_HOST", "localhost")
REDIS_HOST = os.environ.get("REDIS_HOST", "localhost")


# Wait for services to be ready
def wait_for_services(max_retries=30):
    """Wait for database and Redis to be available"""
    for i in range(max_retries):
        try:
            # Check Redis
            r = redis.Redis(host=REDIS_HOST, socket_timeout=2)
            r.ping()

            # Check MySQL
            conn = mysql.connector.connect(
                host=DB_HOST, user="root", password="secret", connection_timeout=2
            )
            conn.close()

            print(f"✓ All services connected after {i + 1} attempts")
            return True
        except Exception as e:
            print(f"Attempt {i + 1}: Waiting for services... ({e})")
            time.sleep(1)

    return False


@app.route("/health")
def health():
    """Health check endpoint"""
    try:
        # Check Redis
        r = redis.Redis(host=REDIS_HOST, socket_timeout=2)
        redis_ok = r.ping()

        # Check database
        conn = mysql.connector.connect(
            host=DB_HOST, user="root", password="secret", connection_timeout=2
        )
        db_ok = conn.is_connected()
        conn.close()

        if redis_ok and db_ok:
            return jsonify(
                {"status": "healthy", "database": "connected", "cache": "connected"}
            )
        else:
            return jsonify(
                {
                    "status": "unhealthy",
                    "database": "connected" if db_ok else "disconnected",
                    "cache": "connected" if redis_ok else "disconnected",
                }
            ), 500

    except Exception as e:
        return jsonify({"status": "unhealthy", "error": str(e)}), 500


@app.route("/")
def home():
    """Home endpoint"""
    return jsonify(
        {"service": "API", "status": "running", "endpoints": ["/health", "/"]}
    )


if __name__ == "__main__":
    print("Starting API server...")

    # Wait for dependencies
    if wait_for_services():
        print("🚀 Starting Flask server on port 3000")
        app.run(host="0.0.0.0", port=3000, debug=False)
    else:
        print("❌ Failed to connect to services")
        exit(1)
