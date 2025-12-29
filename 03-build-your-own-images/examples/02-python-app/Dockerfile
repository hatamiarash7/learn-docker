# ===========================================
# Python Flask Application Dockerfile
# ===========================================
# This Dockerfile demonstrates best practices
# for containerizing Python applications.
# ===========================================

# Use official Python slim image
# Slim variant removes unnecessary packages while keeping essential tools
FROM python:3.11-slim

# Add metadata labels
LABEL maintainer="your-email@example.ir"
LABEL version="1.0"
LABEL description="Flask application example"

# Set environment variables
# PYTHONDONTWRITEBYTECODE: Prevents Python from writing .pyc files
# PYTHONUNBUFFERED: Ensures logs are output immediately
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create a non-root user for security
# Running as root inside containers is a security risk
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Set working directory
WORKDIR /app

# Install dependencies first (better layer caching)
# If requirements.txt doesn't change, this layer is cached
COPY requirements.txt .

# Install Python dependencies
# --no-cache-dir reduces image size by not storing pip cache
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
# This layer rebuilds when code changes
COPY --chown=appuser:appgroup app.py .

# Switch to non-root user
USER appuser

# Document the port
EXPOSE 5000

# Health check for the application
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Run the application
# Use exec form for proper signal handling
CMD ["python", "app.py"]
