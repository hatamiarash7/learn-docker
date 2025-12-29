# Simple Nginx Example

A minimal example of creating a custom Nginx image with static content.

## Files

- `Dockerfile` - The Docker build file
- `index.html` - Static HTML page
- `style.css` - CSS styling

## Build

```bash
docker build -t my-nginx:v1 .
```

## Run

```bash
docker run -d -p 8080:80 --name web my-nginx:v1
```

## Test

```bash
curl http://localhost:8080
# Or open http://localhost:8080 in your browser
```

## Cleanup

```bash
docker rm -f web
docker rmi my-nginx:v1
```
