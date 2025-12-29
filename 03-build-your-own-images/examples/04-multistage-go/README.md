# Multi-Stage Go Build Example

Demonstrates multi-stage builds using Go, showing dramatic image size reduction.

## Why Multi-Stage?

Go compiles to a single binary, so we don't need Go tools in the final image.

| Stage | Image           | Size   |
| ----- | --------------- | ------ |
| Build | golang:1-alpine | ~300MB |
| Final | alpine:3.18     | ~8MB   |

## Files

- `Dockerfile` - Multi-stage Dockerfile
- `main.go` - Simple Go HTTP server
- `go.mod` - Go module file

## Build

```bash
docker build -t go-app:v1 .
```

## Compare Sizes

```bash
# Check final image size
docker images go-app:v1

# Compare with Go build image
docker images golang:1-alpine
```

## Run

```bash
docker run -d -p 8080:8080 --name go-app go-app:v1
```

## Test

```bash
curl http://localhost:8080
curl http://localhost:8080/health
```

## Cleanup

```bash
docker rm -f go-app
docker rmi go-app:v1
```
