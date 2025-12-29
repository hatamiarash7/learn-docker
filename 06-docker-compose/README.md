# 🎼 Docker Compose

Master Docker Compose to orchestrate multi-container applications with ease.

- [🎼 Docker Compose](#-docker-compose)
  - [Introduction to Docker Compose](#introduction-to-docker-compose)
    - [What is Docker Compose?](#what-is-docker-compose)
    - [Why Use Docker Compose?](#why-use-docker-compose)
    - [Basic Workflow](#basic-workflow)
    - [Installing Docker Compose](#installing-docker-compose)
  - [Writing a docker-compose.yml File](#writing-a-docker-composeyml-file)
    - [Basic Structure](#basic-structure)
    - [Common Service Options](#common-service-options)
  - [Defining Services, Networks, and Volumes](#defining-services-networks-and-volumes)
    - [Services](#services)
    - [Networks](#networks)
    - [Volumes](#volumes)
  - [Running Multi-Container Applications](#running-multi-container-applications)
    - [Basic Commands](#basic-commands)
    - [Viewing Status](#viewing-status)
    - [Executing Commands](#executing-commands)
    - [Managing Services](#managing-services)
  - [Scaling Services](#scaling-services)
    - [Basic Scaling](#basic-scaling)
    - [Scaling Example](#scaling-example)
    - [Scaling Considerations](#scaling-considerations)
  - [Environment Variables in Compose](#environment-variables-in-compose)
    - [Methods to Set Environment Variables](#methods-to-set-environment-variables)
      - [1. Direct in compose file](#1-direct-in-compose-file)
      - [2. From .env file](#2-from-env-file)
      - [3. Shell environment interpolation](#3-shell-environment-interpolation)
    - [.env File Example](#env-file-example)
    - [Using Variables in Compose](#using-variables-in-compose)
    - [Environment Variable Precedence](#environment-variable-precedence)
    - [Best Practices for Environment Variables](#best-practices-for-environment-variables)
  - [Healthchecks and depends\_on](#healthchecks-and-depends_on)
    - [Health Checks in Compose](#health-checks-in-compose)
    - [depends\_on with Conditions](#depends_on-with-conditions)
    - [Condition Options](#condition-options)
    - [Complete Example with Health Checks](#complete-example-with-health-checks)
  - [Exercises](#exercises)
    - [🎯 Exercise 1: Basic Compose Application](#-exercise-1-basic-compose-application)
    - [🎯 Exercise 2: Multi-Service Application](#-exercise-2-multi-service-application)
    - [🎯 Exercise 3: Environment Variables](#-exercise-3-environment-variables)
    - [🎯 Exercise 4: Scaling Services](#-exercise-4-scaling-services)
    - [🎯 Exercise 5: Health Checks and Dependencies](#-exercise-5-health-checks-and-dependencies)
  - [📁 Examples Directory](#-examples-directory)
  - [📝 Quick Reference](#-quick-reference)
  - [✅ Checklist](#-checklist)

## Introduction to Docker Compose

### What is Docker Compose?

Docker Compose is a tool for defining and running multi-container Docker applications. With a single YAML file, you can:

- Define all services in your application
- Configure networks and volumes
- Set environment variables
- Manage the entire application lifecycle

### Why Use Docker Compose?

| Without Compose                | With Compose               |
| ------------------------------ | -------------------------- |
| Multiple `docker run` commands | Single `docker-compose up` |
| Manual network creation        | Automatic network setup    |
| Complex startup scripts        | Declarative YAML config    |
| Difficult to share             | Easy to version control    |

### Basic Workflow

```bash
# 1. Create docker-compose.yml
# 2. Start the application
docker-compose up -d

# 3. View status
docker-compose ps

# 4. View logs
docker-compose logs

# 5. Stop the application
docker-compose down
```

### Installing Docker Compose

Docker Compose is included with Docker Desktop. For Linux:

```bash
# Modern Docker (Docker Compose V2 - recommended)
# Included as 'docker compose' (without hyphen)
docker compose version

# Legacy installation (if needed)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

## Writing a docker-compose.yml File

### Basic Structure

```yaml
# Compose file version (optional in V2)
version: "3.9"

# Define services (containers)
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
  
  api:
    build: ./api
    ports:
      - "3000:3000"

# Define networks (optional - auto-created)
networks:
  default:
    driver: bridge

# Define volumes for persistence
volumes:
  data:
```

### Common Service Options

```yaml
services:
  myservice:
    # Image to use
    image: nginx:alpine
    
    # Or build from Dockerfile
    build:
      context: ./app
      dockerfile: Dockerfile
      args:
        - VERSION=1.0
    
    # Container name (optional)
    container_name: my-container
    
    # Port mappings
    ports:
      - "8080:80"        # host:container
      - "127.0.0.1:3000:3000"  # localhost only
    
    # Environment variables
    environment:
      - NODE_ENV=production
      - DEBUG=false
    
    # Or from file
    env_file:
      - .env
      - .env.local
    
    # Volume mounts
    volumes:
      - ./data:/app/data           # bind mount
      - app-data:/var/lib/data     # named volume
      - /tmp:/tmp:ro               # read-only
    
    # Networks
    networks:
      - frontend
      - backend
    
    # Dependencies
    depends_on:
      - db
      - redis
    
    # Restart policy
    restart: unless-stopped
    
    # Resource limits
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    
    # Health check
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    
    # Command override
    command: ["npm", "start"]
    
    # Entrypoint override
    entrypoint: ["/entrypoint.sh"]
    
    # Working directory
    working_dir: /app
    
    # User
    user: "1000:1000"
    
    # Labels
    labels:
      - "app=myapp"
      - "environment=production"
```

## Defining Services, Networks, and Volumes

### Services

Services are the containers that make up your application.

```yaml
services:
  # Web server
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
  
  # Application server
  app:
    build: ./app
    environment:
      - DATABASE_URL=postgres://db:5432/app
    depends_on:
      - db
  
  # Database
  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:
  db-data:
```

### Networks

Compose creates a default network, but you can define custom ones.

```yaml
services:
  frontend:
    image: nginx:alpine
    networks:
      - frontend-net
  
  backend:
    image: node:alpine
    networks:
      - frontend-net
      - backend-net
  
  database:
    image: postgres:alpine
    networks:
      - backend-net

networks:
  frontend-net:
    driver: bridge
  
  backend-net:
    driver: bridge
    # Internal network (no external access)
    internal: true
```

### Volumes

Volumes persist data beyond container lifecycle.

```yaml
services:
  db:
    image: mariadb:latest
    volumes:
      # Named volume
      - db-data:/var/lib/mysql
      # Bind mount
      - ./init:/docker-entrypoint-initdb.d:ro
      # Anonymous volume
      - /var/lib/mysql/logs

volumes:
  # Named volume with default driver
  db-data:
  
  # Named volume with options
  backup-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /mnt/backup
```

## Running Multi-Container Applications

### Basic Commands

```bash
# Start services (foreground)
docker-compose up

# Start services (background/detached)
docker-compose up -d

# Start specific services
docker-compose up -d web api

# Build images before starting
docker-compose up --build

# Force recreate containers
docker-compose up --force-recreate

# Stop services
docker-compose stop

# Stop and remove containers, networks
docker-compose down

# Also remove volumes
docker-compose down -v

# Also remove images
docker-compose down --rmi all
```

### Viewing Status

```bash
# List running services
docker-compose ps

# List all services (including stopped)
docker-compose ps -a

# View logs
docker-compose logs

# Follow logs
docker-compose logs -f

# Logs for specific service
docker-compose logs -f web

# Last N lines
docker-compose logs --tail 100
```

### Executing Commands

```bash
# Run command in running container
docker-compose exec web sh

# Run command in new container
docker-compose run --rm web sh

# Run one-off command
docker-compose run --rm api npm test
```

### Managing Services

```bash
# Restart services
docker-compose restart

# Restart specific service
docker-compose restart web

# Pull latest images
docker-compose pull

# Build/rebuild images
docker-compose build

# Build without cache
docker-compose build --no-cache
```

## Scaling Services

### Basic Scaling

```bash
# Scale a service to multiple replicas
docker-compose up -d --scale web=3

# Scale multiple services
docker-compose up -d --scale web=3 --scale worker=5
```

### Scaling Example

See `examples/scaling/` directory.

```yaml
services:
  web:
    image: nginx:alpine
    # Don't use container_name with scaling
    # Don't use specific host ports with scaling
    ports:
      - "80"  # Random host port
    deploy:
      replicas: 3
  
  loadbalancer:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx-lb.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - web
```

### Scaling Considerations

| ✅ Do                        | ❌ Don't                 |
| ---------------------------- | ------------------------ |
| Use random host ports        | Use fixed host ports     |
| Omit container_name          | Specify container_name   |
| Use load balancer            | Access replicas directly |
| Use shared volumes carefully | Assume file locking      |

## Environment Variables in Compose

### Methods to Set Environment Variables

#### 1. Direct in compose file

```yaml
services:
  app:
    environment:
      - NODE_ENV=production
      - API_KEY=abc123
      # Or map style
      DATABASE_URL: postgres://localhost:5432/db
```

#### 2. From .env file

```yaml
services:
  app:
    env_file:
      - .env
      - .env.local
```

#### 3. Shell environment interpolation

```yaml
services:
  app:
    image: myapp:${VERSION:-latest}
    environment:
      - API_KEY=${API_KEY}
```

### .env File Example

Create a `.env` file in the same directory as `docker-compose.yml`:

```bash
# .env file
# Database configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=admin
DB_PASSWORD=supersecret

# Application settings
APP_ENV=development
APP_DEBUG=true
APP_PORT=3000

# API Keys (don't commit to git!)
API_KEY=your-api-key-here
SECRET_KEY=your-secret-key
```

### Using Variables in Compose

```yaml
services:
  db:
    image: mariadb:${MARIADB_VERSION:-latest}
    environment:
      - MARIADB_ROOT_PASSWORD=${DB_PASSWORD}
      - MARIADB_DATABASE=${DB_NAME}
    ports:
      - "${DB_PORT:-3306}:3306"
  
  app:
    build: .
    environment:
      - DATABASE_URL=mysql://${DB_USER}:${DB_PASSWORD}@db:3306/${DB_NAME}
      - APP_ENV=${APP_ENV:-production}
    ports:
      - "${APP_PORT:-3000}:3000"
```

### Environment Variable Precedence

1. Environment variables from shell
2. `.env` file in project directory
3. `env_file` in compose file
4. `environment` in compose file

### Best Practices for Environment Variables

```bash
# .env.example (commit this)
DB_PASSWORD=change-me
API_KEY=your-key-here

# .env (don't commit - add to .gitignore)
DB_PASSWORD=actual-secret
API_KEY=actual-key
```

Add to `.gitignore`:

```text
.env
.env.local
.env.*.local
```

## Healthchecks and depends_on

### Health Checks in Compose

```yaml
services:
  web:
    image: nginx:alpine
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 5s
  
  api:
    build: ./api
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 10s
  
  db:
    image: mariadb:latest
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
```

### depends_on with Conditions

```yaml
services:
  web:
    image: nginx:alpine
    depends_on:
      api:
        condition: service_healthy
  
  api:
    build: ./api
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 10s
      timeout: 5s
      retries: 5
  
  db:
    image: mariadb:latest
    environment:
      - MARIADB_ROOT_PASSWORD=secret
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s
  
  redis:
    image: redis:alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3
```

### Condition Options

| Condition                        | Description                                |
| -------------------------------- | ------------------------------------------ |
| `service_started`                | Wait for container to start (default)      |
| `service_healthy`                | Wait for healthcheck to pass               |
| `service_completed_successfully` | Wait for container to complete with exit 0 |

### Complete Example with Health Checks

See `examples/healthcheck/` directory.

## Exercises

### 🎯 Exercise 1: Basic Compose Application

Create a simple web application with Nginx and a static site:

1. Create a `docker-compose.yml` file
2. Add an Nginx service
3. Mount a local HTML directory
4. Start and test the application

<details>
<summary>💡 Solution</summary>

```bash
# Create project directory
mkdir compose-basic && cd compose-basic

# Create HTML file
mkdir html
cat > html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Compose Test</title></head>
<body>
    <h1>Hello from Docker Compose!</h1>
    <p>This page is served by Nginx in a container.</p>
</body>
</html>
EOF

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
    restart: unless-stopped
EOF

# Start the application
docker-compose up -d

# Test
curl http://localhost:8080

# View logs
docker-compose logs

# Stop
docker-compose down
```

</details>

### 🎯 Exercise 2: Multi-Service Application

Create a complete application with web server, API, and database:

1. Web: Nginx serving static files
2. API: Simple Python Flask app
3. Database: Redis for caching

<details>
<summary>💡 Solution</summary>

Create the following structure:

```bash
mkdir compose-multi && cd compose-multi
mkdir web api
```

**docker-compose.yml:**

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./web:/usr/share/nginx/html:ro
    depends_on:
      - api
    networks:
      - frontend

  api:
    build: ./api
    ports:
      - "5000:5000"
    environment:
      - REDIS_HOST=redis
    depends_on:
      - redis
    networks:
      - frontend
      - backend

  redis:
    image: redis:alpine
    volumes:
      - redis-data:/data
    networks:
      - backend
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3

networks:
  frontend:
  backend:

volumes:
  redis-data:
```

**api/Dockerfile:**

```dockerfile
FROM python:3.11-alpine
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```

**api/requirements.txt:**

```text
flask==3.0.0
redis==5.0.0
```

**api/app.py:**

```python
import os
from flask import Flask, jsonify
import redis

app = Flask(__name__)
cache = redis.Redis(host=os.environ.get('REDIS_HOST', 'localhost'))

@app.route('/')
def home():
    return jsonify({"status": "ok", "service": "api"})

@app.route('/count')
def count():
    count = cache.incr('hits')
    return jsonify({"count": count})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

**web/index.html:**

```html
<!DOCTYPE html>
<html>
<head><title>Multi-Service App</title></head>
<body>
    <h1>Multi-Service Application</h1>
    <p>Web: Nginx | API: Flask | Cache: Redis</p>
</body>
</html>
```

```bash
# Start
docker-compose up -d --build

# Test
curl http://localhost:8080
curl http://localhost:5000/count

# Stop
docker-compose down -v
```

</details>

### 🎯 Exercise 3: Environment Variables

Practice using environment variables:

1. Create a `.env` file with configuration
2. Use variables in `docker-compose.yml`
3. Override variables at runtime

<details>
<summary>💡 Solution</summary>

```bash
mkdir compose-env && cd compose-env
```

**.env:**

```bash
# Application configuration
APP_NAME=MyApp
APP_PORT=8080
APP_ENV=development

# Database configuration
DB_IMAGE=mariadb:latest
DB_ROOT_PASSWORD=rootsecret
DB_DATABASE=myapp
DB_USER=appuser
DB_PASSWORD=appsecret
```

**docker-compose.yml:**

```yaml
services:
  db:
    image: ${DB_IMAGE}
    environment:
      - MARIADB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
      - MARIADB_DATABASE=${DB_DATABASE}
      - MARIADB_USER=${DB_USER}
      - MARIADB_PASSWORD=${DB_PASSWORD}
    volumes:
      - db-data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  adminer:
    image: adminer:latest
    ports:
      - "${APP_PORT:-8080}:8080"
    environment:
      - ADMINER_DEFAULT_SERVER=db
    depends_on:
      db:
        condition: service_healthy

volumes:
  db-data:
```

```bash
# Start with .env file
docker-compose up -d

# Override at runtime
APP_PORT=9090 docker-compose up -d

# Check configuration
docker-compose config

# Access Adminer
# http://localhost:8080
# Server: db, User: appuser, Password: appsecret

# Stop
docker-compose down -v
```

</details>

### 🎯 Exercise 4: Scaling Services

Practice scaling with a load balancer:

<details>
<summary>💡 Solution</summary>

```bash
mkdir compose-scale && cd compose-scale
```

**docker-compose.yml:**

```yaml
services:
  loadbalancer:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - web

  web:
    image: nginx:alpine
    volumes:
      - ./html:/usr/share/nginx/html:ro
    # No ports - accessed through load balancer
    # No container_name - allows scaling
```

**nginx.conf:**

```nginx
events {
    worker_connections 1024;
}

http {
    upstream backend {
        # Docker DNS resolves 'web' to all instances
        server web:80;
    }

    server {
        listen 80;
        
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

**html/index.html:**

```html
<!DOCTYPE html>
<html>
<body>
    <h1>Hello from a scaled container!</h1>
    <p>Hostname: </p>
    <script>
        fetch('/hostname').then(r => r.text()).then(h => {
            document.querySelector('p').textContent = 'Hostname: ' + h;
        });
    </script>
</body>
</html>
```

```bash
# Start with 3 web instances
docker-compose up -d --scale web=3

# Check running containers
docker-compose ps

# Test load balancing
for i in {1..6}; do curl -s http://localhost:8080; done

# Scale up
docker-compose up -d --scale web=5

# Scale down
docker-compose up -d --scale web=2

# Stop
docker-compose down
```

</details>

### 🎯 Exercise 5: Health Checks and Dependencies

Create an application with proper health checks and startup order:

<details>
<summary>💡 Solution</summary>

```bash
mkdir compose-health && cd compose-health
mkdir api
```

**docker-compose.yml:**

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    depends_on:
      api:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost/"]
      interval: 10s
      timeout: 5s
      retries: 3

  api:
    build: ./api
    environment:
      - DATABASE_HOST=db
      - REDIS_HOST=redis
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:5000/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s

  db:
    image: mariadb:latest
    environment:
      - MARIADB_ROOT_PASSWORD=secret
      - MARIADB_DATABASE=app
    volumes:
      - db-data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s

  redis:
    image: redis:alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3

volumes:
  db-data:
```

**api/Dockerfile:**

```dockerfile
FROM python:3.11-alpine
RUN apk add --no-cache curl
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```

**api/requirements.txt:**

```text
flask==3.0.0
```

**api/app.py:**

```python
from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

@app.route('/')
def home():
    return jsonify({"message": "API is running"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

```bash
# Start and watch startup order
docker-compose up

# In another terminal, watch health status
watch docker-compose ps

# Check service health
docker inspect compose-health-api-1 --format='{{json .State.Health}}' | jq

# Stop
docker-compose down -v
```

</details>

## 📁 Examples Directory

Check the `examples/` directory for complete Compose examples:

```text
examples/
├── basic-web/
│   └── docker-compose.yml
├── web-db/
│   ├── docker-compose.yml
│   └── .env.example
├── full-stack/
│   ├── docker-compose.yml
│   ├── .env.example
│   └── nginx/
├── scaling/
│   ├── docker-compose.yml
│   └── nginx.conf
└── healthcheck/
    ├── docker-compose.yml
    └── api/
```

## 📝 Quick Reference

| Command                           | Description                |
| --------------------------------- | -------------------------- |
| `docker-compose up`               | Create and start services  |
| `docker-compose up -d`            | Start in detached mode     |
| `docker-compose up --build`       | Rebuild images             |
| `docker-compose down`             | Stop and remove containers |
| `docker-compose down -v`          | Also remove volumes        |
| `docker-compose ps`               | List services              |
| `docker-compose logs`             | View logs                  |
| `docker-compose logs -f`          | Follow logs                |
| `docker-compose exec <svc> <cmd>` | Execute command            |
| `docker-compose run <svc> <cmd>`  | Run one-off command        |
| `docker-compose build`            | Build images               |
| `docker-compose pull`             | Pull images                |
| `docker-compose restart`          | Restart services           |
| `docker-compose stop`             | Stop services              |
| `docker-compose config`           | Validate and view config   |
| `docker-compose up --scale web=3` | Scale service              |

## ✅ Checklist

Before completing this course, make sure you can:

- [ ] Write a complete docker-compose.yml file
- [ ] Define services, networks, and volumes
- [ ] Use environment variables effectively
- [ ] Implement health checks
- [ ] Use depends_on with conditions
- [ ] Scale services with load balancing
- [ ] Manage compose applications (start, stop, logs)
- [ ] Debug compose applications

---

⬅️ **Previous:** [Networking with Docker](../05-networking-with-docker/README.md)
