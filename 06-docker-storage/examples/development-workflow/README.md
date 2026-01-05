# Development Workflow with Bind Mounts

This example demonstrates how to use bind mounts for a seamless development experience.

## Features

- **Live HTML/CSS/JS updates** - Edit frontend files and refresh browser
- **Flask hot reload** - Python changes auto-reload
- **API proxy** - Nginx proxies `/api/*` to Flask
- **Redis cache** - Persistent development data

## Quick Start

```bash
# Install Flask dependencies (needed for API)
pip install -r backend/requirements.txt

# Start all services
docker compose up -d

# View logs
docker compose logs -f
```

## Access

- **Frontend**: <http://localhost:3000>
- **API directly**: <http://localhost:5000/api/hello>

## Development Workflow

### Frontend Changes

1. Edit `frontend/index.html`
2. Refresh browser - changes appear immediately!

### Backend Changes

1. Edit `backend/app.py`
2. Flask auto-reloads (watch the logs)
3. Test your changes

### Example: Add a new API endpoint

```python
# Add to backend/app.py
@app.route('/api/greet/<name>')
def greet(name):
    return jsonify({
        'greeting': f'Hello, {name}!'
    })
```

Then visit: <http://localhost:5000/api/greet/Alice>

## Architecture

```
Browser (localhost:3000)
    │
    ▼
┌─────────────────┐
│  Nginx Frontend │ ──(bind mount)── frontend/
│    Port 3000    │
└────────┬────────┘
         │ /api/*
         ▼
┌─────────────────┐
│   Flask API     │ ──(bind mount)── backend/
│    Port 5000    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│     Redis       │ ──(named volume)── cache-data
│    Port 6379    │
└─────────────────┘
```

## Cleanup

```bash
docker compose down
```
