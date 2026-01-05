"""
ShopStream Auth Service
=======================
Handles user authentication, registration, and JWT token management.
"""

import hashlib
import os
import secrets
import sys
from datetime import datetime, timedelta
from functools import wraps

import jwt
import mysql.connector
from flask import Flask, jsonify, request
from flask_cors import CORS
from mysql.connector import pooling

app = Flask(__name__)
CORS(app)

# ============================================
# Configuration
# ============================================


class Config:
    SECRET_KEY = os.environ.get("JWT_SECRET", "development-secret-key")
    TOKEN_EXPIRY_HOURS = int(os.environ.get("TOKEN_EXPIRY_HOURS", 24))

    DB_CONFIG = {
        "host": os.environ.get("DB_HOST", "mariadb"),
        "port": int(os.environ.get("DB_PORT", 3306)),
        "user": os.environ.get("DB_USER", "appuser"),
        "password": os.environ.get("DB_PASSWORD", "apppassword"),
        "database": os.environ.get("DB_NAME", "shopstream"),
    }


# ============================================
# Database Connection Pool
# ============================================

db_pool = None


def init_db_pool():
    global db_pool
    try:
        db_pool = pooling.MySQLConnectionPool(
            pool_name="auth_pool",
            pool_size=5,
            pool_reset_session=True,
            **Config.DB_CONFIG,
        )
        print("✓ Database pool initialized")
        return True
    except Exception as e:
        print(f"✗ Database pool error: {e}")
        return False


def get_db():
    """Get a database connection from the pool."""
    if db_pool is None:
        init_db_pool()
    return db_pool.get_connection()


def init_tables():
    """Initialize database tables."""
    try:
        conn = get_db()
        cursor = conn.cursor()

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                email VARCHAR(255) NOT NULL UNIQUE,
                password_hash VARCHAR(255) NOT NULL,
                salt VARCHAR(64) NOT NULL,
                role ENUM('user', 'admin') DEFAULT 'user',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                last_login TIMESTAMP NULL,
                is_active BOOLEAN DEFAULT TRUE,
                INDEX idx_email (email)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS refresh_tokens (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                token VARCHAR(255) NOT NULL UNIQUE,
                expires_at TIMESTAMP NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                INDEX idx_token (token),
                INDEX idx_user (user_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)

        conn.commit()
        cursor.close()
        conn.close()
        print("✓ Database tables initialized")
        return True
    except Exception as e:
        print(f"✗ Table initialization error: {e}")
        return False


# ============================================
# Password Hashing
# ============================================


def hash_password(password: str, salt: str = None) -> tuple:
    """Hash a password with a salt."""
    if salt is None:
        salt = secrets.token_hex(32)

    password_hash = hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt.encode("utf-8"),
        100000,  # iterations
    ).hex()

    return password_hash, salt


def verify_password(password: str, password_hash: str, salt: str) -> bool:
    """Verify a password against its hash."""
    computed_hash, _ = hash_password(password, salt)
    return secrets.compare_digest(computed_hash, password_hash)


# ============================================
# JWT Token Management
# ============================================


def create_token(user_data: dict) -> str:
    """Create a JWT token for a user."""
    payload = {
        "id": user_data["id"],
        "email": user_data["email"],
        "name": user_data["name"],
        "role": user_data.get("role", "user"),
        "iat": datetime.utcnow(),
        "exp": datetime.utcnow() + timedelta(hours=Config.TOKEN_EXPIRY_HOURS),
    }

    return jwt.encode(payload, Config.SECRET_KEY, algorithm="HS256")


def create_refresh_token(user_id: int) -> str:
    """Create and store a refresh token."""
    token = secrets.token_urlsafe(64)
    expires_at = datetime.utcnow() + timedelta(days=30)

    try:
        conn = get_db()
        cursor = conn.cursor()

        # Remove old refresh tokens for this user
        cursor.execute("DELETE FROM refresh_tokens WHERE user_id = %s", (user_id,))

        # Insert new refresh token
        cursor.execute(
            "INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES (%s, %s, %s)",
            (user_id, token, expires_at),
        )

        conn.commit()
        cursor.close()
        conn.close()

        return token
    except Exception as e:
        print(f"Refresh token error: {e}")
        return None


# ============================================
# Request Authentication
# ============================================


def token_required(f):
    """Decorator to require valid JWT token."""

    @wraps(f)
    def decorated(*args, **kwargs):
        token = None

        if "Authorization" in request.headers:
            auth_header = request.headers["Authorization"]
            if auth_header.startswith("Bearer "):
                token = auth_header[7:]

        if not token:
            return jsonify({"error": "Token is missing"}), 401

        try:
            data = jwt.decode(token, Config.SECRET_KEY, algorithms=["HS256"])
            request.current_user = data
        except jwt.ExpiredSignatureError:
            return jsonify({"error": "Token has expired"}), 401
        except jwt.InvalidTokenError:
            return jsonify({"error": "Invalid token"}), 401

        return f(*args, **kwargs)

    return decorated


# ============================================
# Health Check
# ============================================


@app.route("/health", methods=["GET"])
def health_check():
    """Health check endpoint."""
    health = {
        "status": "healthy",
        "service": "auth-service",
        "timestamp": datetime.utcnow().isoformat(),
    }

    # Check database connection
    try:
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.fetchone()
        cursor.close()
        conn.close()
        health["database"] = "connected"
    except Exception as e:
        health["database"] = "disconnected"
        health["status"] = "degraded"
        health["error"] = str(e)

    status_code = 200 if health["status"] == "healthy" else 503
    return jsonify(health), status_code


# ============================================
# Authentication Routes
# ============================================


@app.route("/register", methods=["POST"])
def register():
    """Register a new user."""
    data = request.get_json()

    # Validate input
    if not data:
        return jsonify({"error": "No data provided"}), 400

    required_fields = ["name", "email", "password"]
    for field in required_fields:
        if field not in data or not data[field]:
            return jsonify({"error": f"{field} is required"}), 400

    name = data["name"].strip()
    email = data["email"].strip().lower()
    password = data["password"]

    # Validate email format
    if "@" not in email or "." not in email:
        return jsonify({"error": "Invalid email format"}), 400

    # Validate password strength
    if len(password) < 6:
        return jsonify({"error": "Password must be at least 6 characters"}), 400

    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)

        # Check if email already exists
        cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
        if cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({"error": "Email already registered"}), 409

        # Hash password
        password_hash, salt = hash_password(password)

        # Insert user
        cursor.execute(
            """INSERT INTO users (name, email, password_hash, salt) 
               VALUES (%s, %s, %s, %s)""",
            (name, email, password_hash, salt),
        )

        user_id = cursor.lastrowid
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify(
            {"message": "User registered successfully", "userId": user_id}
        ), 201

    except Exception as e:
        print(f"Registration error: {e}")
        return jsonify({"error": "Registration failed"}), 500


@app.route("/login", methods=["POST"])
def login():
    """Authenticate user and return JWT token."""
    data = request.get_json()

    if not data or "email" not in data or "password" not in data:
        return jsonify({"error": "Email and password are required"}), 400

    email = data["email"].strip().lower()
    password = data["password"]

    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """SELECT id, name, email, password_hash, salt, role, is_active 
               FROM users WHERE email = %s""",
            (email,),
        )
        user = cursor.fetchone()

        if not user:
            cursor.close()
            conn.close()
            return jsonify({"error": "Invalid email or password"}), 401

        if not user["is_active"]:
            cursor.close()
            conn.close()
            return jsonify({"error": "Account is deactivated"}), 403

        if not verify_password(password, user["password_hash"], user["salt"]):
            cursor.close()
            conn.close()
            return jsonify({"error": "Invalid email or password"}), 401

        # Update last login
        cursor.execute(
            "UPDATE users SET last_login = NOW() WHERE id = %s", (user["id"],)
        )
        conn.commit()
        cursor.close()
        conn.close()

        # Create tokens
        token = create_token(
            {
                "id": user["id"],
                "email": user["email"],
                "name": user["name"],
                "role": user["role"],
            }
        )

        refresh_token = create_refresh_token(user["id"])

        return jsonify(
            {
                "token": token,
                "refreshToken": refresh_token,
                "user": {
                    "id": user["id"],
                    "name": user["name"],
                    "email": user["email"],
                    "role": user["role"],
                },
            }
        )

    except Exception as e:
        print(f"Login error: {e}")
        return jsonify({"error": "Login failed"}), 500


@app.route("/refresh", methods=["POST"])
def refresh():
    """Refresh JWT token using refresh token."""
    data = request.get_json()

    if not data or "refreshToken" not in data:
        return jsonify({"error": "Refresh token is required"}), 400

    refresh_token = data["refreshToken"]

    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)

        # Find valid refresh token
        cursor.execute(
            """SELECT rt.user_id, u.id, u.name, u.email, u.role
               FROM refresh_tokens rt
               JOIN users u ON rt.user_id = u.id
               WHERE rt.token = %s AND rt.expires_at > NOW() AND u.is_active = TRUE""",
            (refresh_token,),
        )
        result = cursor.fetchone()

        if not result:
            cursor.close()
            conn.close()
            return jsonify({"error": "Invalid or expired refresh token"}), 401

        cursor.close()
        conn.close()

        # Create new access token
        token = create_token(
            {
                "id": result["id"],
                "email": result["email"],
                "name": result["name"],
                "role": result["role"],
            }
        )

        return jsonify({"token": token})

    except Exception as e:
        print(f"Token refresh error: {e}")
        return jsonify({"error": "Token refresh failed"}), 500


@app.route("/me", methods=["GET"])
@token_required
def get_current_user():
    """Get current user information."""
    return jsonify(request.current_user)


@app.route("/change-password", methods=["POST"])
@token_required
def change_password():
    """Change user password."""
    data = request.get_json()

    if not data or "currentPassword" not in data or "newPassword" not in data:
        return jsonify({"error": "Current and new passwords are required"}), 400

    if len(data["newPassword"]) < 6:
        return jsonify({"error": "New password must be at least 6 characters"}), 400

    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)

        user_id = request.current_user["id"]

        # Get current password hash
        cursor.execute(
            "SELECT password_hash, salt FROM users WHERE id = %s", (user_id,)
        )
        user = cursor.fetchone()

        if not verify_password(
            data["currentPassword"], user["password_hash"], user["salt"]
        ):
            cursor.close()
            conn.close()
            return jsonify({"error": "Current password is incorrect"}), 401

        # Hash new password
        new_hash, new_salt = hash_password(data["newPassword"])

        # Update password
        cursor.execute(
            "UPDATE users SET password_hash = %s, salt = %s WHERE id = %s",
            (new_hash, new_salt, user_id),
        )

        # Invalidate all refresh tokens
        cursor.execute("DELETE FROM refresh_tokens WHERE user_id = %s", (user_id,))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"message": "Password changed successfully"})

    except Exception as e:
        print(f"Password change error: {e}")
        return jsonify({"error": "Password change failed"}), 500


# ============================================
# Admin Routes
# ============================================


@app.route("/users", methods=["GET"])
@token_required
def list_users():
    """List all users (admin only)."""
    if request.current_user.get("role") != "admin":
        return jsonify({"error": "Admin access required"}), 403

    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """SELECT id, name, email, role, is_active, created_at, last_login 
               FROM users ORDER BY created_at DESC"""
        )
        users = cursor.fetchall()

        cursor.close()
        conn.close()

        # Convert datetime objects to strings
        for user in users:
            if user["created_at"]:
                user["created_at"] = user["created_at"].isoformat()
            if user["last_login"]:
                user["last_login"] = user["last_login"].isoformat()

        return jsonify(users)

    except Exception as e:
        print(f"List users error: {e}")
        return jsonify({"error": "Failed to list users"}), 500


# ============================================
# Error Handlers
# ============================================


@app.errorhandler(404)
def not_found(e):
    return jsonify({"error": "Endpoint not found"}), 404


@app.errorhandler(500)
def server_error(e):
    return jsonify({"error": "Internal server error"}), 500


# ============================================
# Application Startup
# ============================================


def wait_for_db(max_retries=30, retry_interval=2):
    """Wait for database to become available."""
    import time

    for i in range(max_retries):
        try:
            if init_db_pool():
                init_tables()
                return True
        except Exception as e:
            print(f"Waiting for database... ({i + 1}/{max_retries})")
            time.sleep(retry_interval)

    print("✗ Database connection failed after maximum retries")
    return False


if __name__ == "__main__":
    print("""
╔═══════════════════════════════════════════════╗
║         ShopStream Auth Service               ║
╠═══════════════════════════════════════════════╣
║  Port: 5000                                   ║
║  Health: /health                              ║
╚═══════════════════════════════════════════════╝
    """)

    if wait_for_db():
        app.run(host="0.0.0.0", port=5000, debug=os.environ.get("DEBUG", False))
    else:
        print("Failed to start: Database unavailable")
        sys.exit(1)
