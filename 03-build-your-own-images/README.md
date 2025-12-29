# 🏗️ Build Your Own Images

This section teaches you how to create custom Docker images using Dockerfile.

- [🏗️ Build Your Own Images](#️-build-your-own-images)
  - [Dockerfile Basics](#dockerfile-basics)
    - [What is a Dockerfile?](#what-is-a-dockerfile)
    - [Common Instructions](#common-instructions)
  - [Writing a Dockerfile](#writing-a-dockerfile)
    - [Example 1: Simple Web Server](#example-1-simple-web-server)
    - [Example 2: Python Application](#example-2-python-application)
    - [Example 3: Node.js Application](#example-3-nodejs-application)
  - [Building Images](#building-images)
    - [Basic Build Commands](#basic-build-commands)
    - [Build Context](#build-context)
    - [Using .dockerignore](#using-dockerignore)
  - [Best Practices](#best-practices)
    - [1. Use Official Base Images](#1-use-official-base-images)
    - [2. Use Specific Tags](#2-use-specific-tags)
    - [3. Minimize Layers](#3-minimize-layers)
    - [4. Order Instructions by Change Frequency](#4-order-instructions-by-change-frequency)
    - [5. Use Non-Root User](#5-use-non-root-user)
    - [6. Clean Up in Same Layer](#6-clean-up-in-same-layer)
  - [Multi-Stage Builds](#multi-stage-builds)
    - [Benefits](#benefits)
    - [Example: Go Application](#example-go-application)
    - [Example: Node.js with Build Step](#example-nodejs-with-build-step)
  - [Multi-Arch Builds](#multi-arch-builds)
    - [Using Docker Buildx](#using-docker-buildx)
    - [Dockerfile for Multi-Arch](#dockerfile-for-multi-arch)
  - [Healthchecks](#healthchecks)
    - [Syntax](#syntax)
    - [Example: Web Server Healthcheck](#example-web-server-healthcheck)
    - [Example: Without curl (using wget)](#example-without-curl-using-wget)
    - [Checking Health Status](#checking-health-status)
  - [CMD vs ENTRYPOINT](#cmd-vs-entrypoint)
    - [CMD](#cmd)
    - [ENTRYPOINT](#entrypoint)
    - [Combining Both](#combining-both)
    - [Shell Form vs Exec Form](#shell-form-vs-exec-form)
    - [Comparison Table](#comparison-table)
  - [Exercises](#exercises)
    - [🎯 Exercise 1: Build a Static Website](#-exercise-1-build-a-static-website)
    - [🎯 Exercise 2: Multi-Stage Build](#-exercise-2-multi-stage-build)
    - [🎯 Exercise 3: Healthcheck](#-exercise-3-healthcheck)
    - [🎯 Exercise 4: CMD vs ENTRYPOINT](#-exercise-4-cmd-vs-entrypoint)
    - [🎯 Exercise 5: Optimized Dockerfile](#-exercise-5-optimized-dockerfile)
  - [📁 Examples Directory Structure](#-examples-directory-structure)
  - [✅ Checklist](#-checklist)

## Dockerfile Basics

### What is a Dockerfile?

A Dockerfile is a text file containing instructions to build a Docker image.

```dockerfile
# Basic Dockerfile structure
FROM base_image:tag       # Start from a base image
LABEL company="MCI"       # Add metadata
RUN command               # Execute commands
COPY source dest          # Copy files
WORKDIR /app              # Set working directory
EXPOSE 8080               # Document exposed ports
CMD ["executable"]        # Default command
```

### Common Instructions

| Instruction   | Purpose                  | Example                                     |
| ------------- | ------------------------ | ------------------------------------------- |
| `FROM`        | Base image               | `FROM alpine:3.18`                          |
| `RUN`         | Execute command          | `RUN apk add nginx`                         |
| `COPY`        | Copy files from host     | `COPY ./app /app`                           |
| `ADD`         | Copy + extract archives  | `ADD app.tar.gz /app`                       |
| `WORKDIR`     | Set working directory    | `WORKDIR /app`                              |
| `ENV`         | Set environment variable | `ENV NODE_ENV=production`                   |
| `ARG`         | Build-time variable      | `ARG VERSION=1.0`                           |
| `EXPOSE`      | Document port            | `EXPOSE 8080`                               |
| `VOLUME`      | Create mount point       | `VOLUME /data`                              |
| `USER`        | Set user                 | `USER appuser`                              |
| `CMD`         | Default command          | `CMD ["nginx", "-g", "daemon off;"]`        |
| `ENTRYPOINT`  | Main executable          | `ENTRYPOINT ["python"]`                     |
| `HEALTHCHECK` | Container health check   | `HEALTHCHECK CMD curl -f http://localhost/` |
| `LABEL`       | Add metadata             | `LABEL version="1.0"`                       |

## Writing a Dockerfile

### Example 1: Simple Web Server

Navigate to the `examples/01-simple-nginx/` directory.

```bash
cd examples/01-simple-nginx/
docker build -t my-nginx .
docker run -d -p 8080:80 my-nginx
# Visit http://localhost:8080
```

### Example 2: Python Application

Navigate to the `examples/02-python-app/` directory.

```bash
cd examples/02-python-app/
docker build -t my-python-app .
docker run -d -p 5000:5000 my-python-app
# Visit http://localhost:5000
```

### Example 3: Node.js Application

Navigate to the `examples/03-nodejs-app/` directory.

```bash
cd examples/03-nodejs-app/
docker build -t my-node-app .
docker run -d -p 3000:3000 my-node-app
# Visit http://localhost:3000
```

## Building Images

### Basic Build Commands

```bash
# Build from current directory
docker build -t my-image .

# Build with a specific Dockerfile
docker build -f Dockerfile.dev -t my-image:dev .

# Build with build arguments
docker build --build-arg VERSION=2.0 -t my-image .

# Build without cache
docker build --no-cache -t my-image .

# Build with progress output
docker build --progress=plain -t my-image .

# Build and see all output
docker build -t my-image . 2>&1 | tee build.log
```

### Build Context

The build context is the set of files at the specified path.

```bash
# Current directory as context
docker build -t my-image .

# Specific directory as context
docker build -t my-image ./my-app

# Build with stdin Dockerfile
docker build -t my-image - < Dockerfile

# Build from Git repository
docker build -t my-image https://github.com/user/repo.git
```

### Using .dockerignore

Create a `.dockerignore` file to exclude files from the build context:

```text
.git
.gitignore
node_modules
*.log
*.md
Dockerfile*
docker-compose*.yml
.env
.env.*
__pycache__
*.pyc
.pytest_cache
.coverage
```

## Best Practices

### 1. Use Official Base Images

```dockerfile
# ✅ Good - Official image
FROM python:3.11-alpine

# ❌ Avoid - Unknown source
FROM random-user/python-image
```

### 2. Use Specific Tags

```dockerfile
# ✅ Good - Specific version
FROM node:20-alpine3.18

# ❌ Avoid - Latest can change
FROM node:latest
```

### 3. Minimize Layers

```dockerfile
# ✅ Good - Single RUN instruction
RUN apk update && \
    apk add --no-cache \
        curl \
        git \
        vim && \
    rm -rf /var/cache/apk/*

# ❌ Avoid - Multiple RUN instructions
RUN apk update
RUN apk add curl
RUN apk add git
RUN apk add vim
```

### 4. Order Instructions by Change Frequency

```dockerfile
# ✅ Good - Least changing first
FROM node:20-alpine

# System dependencies (rarely change)
RUN apk add --no-cache python3 make g++

# App dependencies (change sometimes)
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# App code (changes frequently)
COPY . .

CMD ["node", "server.js"]
```

### 5. Use Non-Root User

```dockerfile
FROM alpine:3.18

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Switch to non-root user
USER appuser

WORKDIR /home/appuser/app
COPY --chown=appuser:appgroup . .

CMD ["./my-app"]
```

### 6. Clean Up in Same Layer

```dockerfile
# ✅ Good - Clean in same layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        package1 \
        package2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ❌ Bad - Cleanup in separate layer doesn't save space
RUN apt-get update
RUN apt-get install -y package1
RUN apt-get clean  # This doesn't reduce image size!
```

## Multi-Stage Builds

Multi-stage builds allow you to use multiple FROM statements to create optimized final images.

### Benefits

- Smaller final images
- No build tools in production image
- Better security
- Cleaner Dockerfile

### Example: Go Application

See `examples/04-multistage-go/`

```dockerfile
# Stage 1: Build
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.* ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Stage 2: Runtime
FROM alpine:3.18

RUN apk --no-cache add ca-certificates
WORKDIR /app

# Copy only the binary from builder
COPY --from=builder /app/main .

CMD ["./main"]
```

### Example: Node.js with Build Step

See `examples/05-multistage-node/`

```dockerfile
# Stage 1: Install dependencies and build
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Stage 2: Production
FROM node:20-alpine

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

ENV NODE_ENV=production
EXPOSE 3000
CMD ["npm", "start"]
```

## Multi-Arch Builds

Build images that work on multiple CPU architectures (amd64, arm64, etc.).

### Using Docker Buildx

```bash
# Create a new builder
docker buildx create --name mybuilder --use

# Build for multiple architectures
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t username/my-image:latest \
    --push \
    .

# Build and load locally (single arch only)
docker buildx build \
    --platform linux/amd64 \
    -t my-image:latest \
    --load \
    .

# Inspect builder
docker buildx inspect
```

### Dockerfile for Multi-Arch

```dockerfile
FROM --platform=$TARGETPLATFORM alpine:3.18

ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN echo "Building on $BUILDPLATFORM for $TARGETPLATFORM"

# Platform-specific installations can use these ARGs
RUN apk add --no-cache curl

CMD ["echo", "Hello from multi-arch image!"]
```

## Healthchecks

Healthchecks allow Docker to monitor if your container is working properly.

### Syntax

```dockerfile
HEALTHCHECK [OPTIONS] CMD command

# Options:
# --interval=30s     (time between checks)
# --timeout=10s      (max time for check to complete)
# --start-period=5s  (grace period for startup)
# --retries=3        (consecutive failures needed)
```

### Example: Web Server Healthcheck

```dockerfile
FROM nginx:alpine

# Copy custom configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Healthcheck using curl
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Example: Without curl (using wget)

```dockerfile
FROM alpine:3.18

RUN apk add --no-cache python3

COPY app.py /app.py

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget -q --spider http://localhost:8000/health || exit 1

CMD ["python3", "/app.py"]
```

### Checking Health Status

```bash
# View health status
docker ps
# Shows (healthy), (unhealthy), or (starting)

# Inspect health
docker inspect --format='{{json .State.Health}}' container_name
```

## CMD vs ENTRYPOINT

Understanding the difference between CMD and ENTRYPOINT is crucial.

### CMD

- Provides default arguments
- Can be overridden at runtime
- Use for default behavior

```dockerfile
FROM alpine
CMD ["echo", "Hello, World!"]
```

```bash
docker run my-image              # Output: Hello, World!
docker run my-image echo "Hi"    # Output: Hi (CMD overridden)
```

### ENTRYPOINT

- Defines the main executable
- Arguments are appended
- Use for container as executable

```dockerfile
FROM alpine
ENTRYPOINT ["echo"]
CMD ["Hello, World!"]
```

```bash
docker run my-image              # Output: Hello, World!
docker run my-image "Hi there"   # Output: Hi there
```

### Combining Both

```dockerfile
FROM python:3.11-alpine

WORKDIR /app
COPY app.py .

# ENTRYPOINT is the executable
ENTRYPOINT ["python", "app.py"]

# CMD provides default arguments
CMD ["--help"]
```

```bash
docker run my-image                    # Runs: python app.py --help
docker run my-image --port 8080        # Runs: python app.py --port 8080
```

### Shell Form vs Exec Form

```dockerfile
# Exec form (preferred) - runs directly
CMD ["nginx", "-g", "daemon off;"]
ENTRYPOINT ["python", "app.py"]

# Shell form - runs through /bin/sh -c
CMD nginx -g daemon off;
ENTRYPOINT python app.py
```

**Exec form benefits:**

- Proper signal handling (SIGTERM, etc.)
- No shell process as PID 1
- Cleaner process tree

### Comparison Table

| Scenario                | ENTRYPOINT          | CMD          | Result                |
| ----------------------- | ------------------- | ------------ | --------------------- |
| Container as executable | `["app"]`           | `["--help"]` | `app --help`          |
| Default command         | Not set             | `["nginx"]`  | `nginx`               |
| Wrapper script          | `["entrypoint.sh"]` | `["nginx"]`  | `entrypoint.sh nginx` |

See `examples/06-cmd-entrypoint/` for practical examples.

## Exercises

### 🎯 Exercise 1: Build a Static Website

Create a Docker image for a static website using Nginx.

1. Create an `index.html` file
2. Write a Dockerfile based on `nginx:alpine`
3. Copy your HTML into the nginx serving directory
4. Build and run the container

<details>
<summary>💡 Solution</summary>

```bash
# Create project directory
mkdir my-website && cd my-website

# Create index.html
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>My Docker Website</title></head>
<body>
    <h1>Hello from Docker!</h1>
    <p>This is served by Nginx in a container.</p>
</body>
</html>
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# Build
docker build -t my-website .

# Run
docker run -d -p 8080:80 --name website my-website

# Test
curl http://localhost:8080

# Cleanup
docker rm -f website
```

</details>

### 🎯 Exercise 2: Multi-Stage Build

Create a multi-stage build for a simple C program.

1. Create a "Hello, Docker!" C program
2. Use `gcc:alpine` to compile
3. Use `alpine` for the final image
4. Compare sizes

<details>
<summary>💡 Solution</summary>

```bash
# Create project directory
mkdir c-hello && cd c-hello

# Create hello.c
cat > hello.c << 'EOF'
#include <stdio.h>
int main() {
    printf("Hello, Docker!\n");
    return 0;
}
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
# Stage 1: Build
FROM gcc:13-bookworm AS builder
WORKDIR /app
COPY hello.c .
RUN gcc -static -o hello hello.c

# Stage 2: Runtime
FROM alpine:3.18
COPY --from=builder /app/hello /hello
CMD ["/hello"]
EOF

# Build
docker build -t c-hello .

# Run
docker run c-hello

# Check sizes
echo "Final image size:"
docker images c-hello --format "{{.Size}}"

echo "GCC image size (for comparison):"
docker images gcc:13-bookworm --format "{{.Size}}"
```

</details>

### 🎯 Exercise 3: Healthcheck

Create an image with a working healthcheck.

1. Create a simple Python HTTP server
2. Add a healthcheck
3. Build and run
4. Observe the health status

<details>
<summary>💡 Solution</summary>

```bash
# Create project directory
mkdir health-check && cd health-check

# Create app.py
cat > app.py << 'EOF'
from http.server import HTTPServer, BaseHTTPRequestHandler

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'OK')
        else:
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'Hello from Python!')
    
    def log_message(self, format, *args):
        pass  # Suppress logs

HTTPServer(('0.0.0.0', 8000), Handler).serve_forever()
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.11-alpine

WORKDIR /app
COPY app.py .

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q --spider http://localhost:8000/health || exit 1

EXPOSE 8000
CMD ["python", "app.py"]
EOF

# Build
docker build -t health-app .

# Run
docker run -d --name health-test health-app

# Watch health status (run multiple times)
docker ps --format "{{.Names}}: {{.Status}}"

# Wait and check again
sleep 15
docker ps --format "{{.Names}}: {{.Status}}"

# Inspect health details
docker inspect --format='{{json .State.Health}}' health-test | jq

# Cleanup
docker rm -f health-test
```

</details>

### 🎯 Exercise 4: CMD vs ENTRYPOINT

Create an image that demonstrates CMD and ENTRYPOINT behavior.

<details>
<summary>💡 Solution</summary>

```bash
# Create project directory
mkdir cmd-entry && cd cmd-entry

# Dockerfile with CMD only
cat > Dockerfile.cmd << 'EOF'
FROM alpine:3.18
CMD ["echo", "Default message"]
EOF

# Dockerfile with ENTRYPOINT only
cat > Dockerfile.entry << 'EOF'
FROM alpine:3.18
ENTRYPOINT ["echo"]
EOF

# Dockerfile with both
cat > Dockerfile.both << 'EOF'
FROM alpine:3.18
ENTRYPOINT ["echo"]
CMD ["Default message"]
EOF

# Build all
docker build -f Dockerfile.cmd -t test-cmd .
docker build -f Dockerfile.entry -t test-entry .
docker build -f Dockerfile.both -t test-both .

# Test CMD only
echo "=== CMD only ==="
docker run test-cmd                    # Output: Default message
docker run test-cmd echo "Override"    # Output: Override

# Test ENTRYPOINT only
echo "=== ENTRYPOINT only ==="
docker run test-entry                  # Output: (empty)
docker run test-entry "Hello"          # Output: Hello

# Test both
echo "=== Both ==="
docker run test-both                   # Output: Default message
docker run test-both "Custom message"  # Output: Custom message
```

</details>

### 🎯 Exercise 5: Optimized Dockerfile

Optimize a poorly written Dockerfile.

**Bad Dockerfile:**

```dockerfile
FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
COPY . /app
RUN pip3 install flask
WORKDIR /app
USER root
CMD python3 app.py
```

<details>
<summary>💡 Solution</summary>

```dockerfile
# Optimized Dockerfile
FROM python:3.11-slim

# Create non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app

# Install dependencies first (better caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser

EXPOSE 5000

# Use exec form
CMD ["python3", "app.py"]
```

**Improvements made:**

1. ✅ Specific base image tag (not `latest`)
2. ✅ Smaller base image (`python:slim` vs `ubuntu`)
3. ✅ Single RUN layer for apt commands
4. ✅ Non-root user
5. ✅ Dependencies installed before code copy
6. ✅ Exec form for CMD
7. ✅ No pip cache

</details>

## 📁 Examples Directory Structure

```text
examples/
├── 01-simple-nginx/
│   ├── Dockerfile
│   ├── index.html
│   └── README.md
├── 02-python-app/
│   ├── Dockerfile
│   ├── app.py
│   ├── requirements.txt
│   └── README.md
├── 03-nodejs-app/
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│   └── README.md
├── 04-multistage-go/
│   ├── Dockerfile
│   ├── main.go
│   ├── go.mod
│   └── README.md
├── 05-multistage-node/
│   ├── Dockerfile
│   ├── package.json
│   ├── src/
│   └── README.md
└── 06-cmd-entrypoint/
    ├── Dockerfile.cmd
    ├── Dockerfile.entrypoint
    ├── Dockerfile.both
    └── README.md
```

## ✅ Checklist

Before moving to the next section, make sure you can:

- [ ] Write a basic Dockerfile
- [ ] Build images with docker build
- [ ] Use .dockerignore effectively
- [ ] Apply Dockerfile best practices
- [ ] Create multi-stage builds
- [ ] Add healthchecks to images
- [ ] Understand CMD vs ENTRYPOINT
- [ ] Build multi-arch images

---

⬅️ **Previous:** [Docker Images](../02-docker-images/README.md)

➡️ **Next:** [Managing Containers](../04-managing-containers/README.md)
