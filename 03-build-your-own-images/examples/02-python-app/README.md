# Python Flask Application Example

A simple Python Flask application demonstrating:

- Python dependencies management
- Flask web framework
- Environment variables
- Proper Dockerfile structure

## Files

- `Dockerfile` - Multi-stage build for Python
- `app.py` - Flask application
- `requirements.txt` - Python dependencies

## Build

```bash
docker build -t flask-app:v1 .
```

## Run

```bash
# Basic run
docker run -d -p 5000:5000 --name flask flask-app:v1

# With environment variable
docker run -d -p 5000:5000 -e APP_NAME="My Custom App" --name flask flask-app:v1
```

## Test

```bash
# Home page
curl http://localhost:5000

# Health check endpoint
curl http://localhost:5000/health

# JSON API endpoint
curl http://localhost:5000/api/info
```

## Cleanup

```bash
docker rm -f flask
docker rmi flask-app:v1
```
