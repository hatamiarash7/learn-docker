# Node.js Application Example

A simple Node.js Express application demonstrating:

- Node.js containerization
- npm dependency management
- Express web framework
- Environment variable configuration

## Files

- `Dockerfile` - Optimized Node.js Dockerfile
- `server.js` - Express server
- `package.json` - Node.js dependencies
- `.dockerignore` - Files to exclude from build

## Build

```bash
docker build -t node-app:v1 .
```

## Run

```bash
# Basic run
docker run -d -p 3000:3000 --name node-app node-app:v1

# With custom port
docker run -d -p 8080:3000 -e PORT=3000 --name node-app node-app:v1
```

## Test

```bash
# Home page
curl http://localhost:3000

# Health check
curl http://localhost:3000/health

# API endpoint
curl http://localhost:3000/api/status
```

## Cleanup

```bash
docker rm -f node-app
docker rmi node-app:v1
```
