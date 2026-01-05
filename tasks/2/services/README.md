# ShopStream Application Services

This directory contains all the microservices for the ShopStream e-commerce platform. The code is provided ready-to-use - your job is to create the Dockerfiles and deploy them to the Swarm cluster.

## Services Overview

| Service                  | Language       | Port | Description                            |
| ------------------------ | -------------- | ---- | -------------------------------------- |
| **frontend**             | Static HTML/JS | 80   | Vue.js-like SPA served by Nginx        |
| **api-gateway**          | Node.js        | 3000 | Central API gateway with rate limiting |
| **auth-service**         | Python/Flask   | 5000 | User authentication and JWT tokens     |
| **product-service**      | Node.js        | 3000 | Product catalog with Elasticsearch     |
| **order-service**        | Python/Flask   | 5000 | Order processing with RabbitMQ         |
| **notification-service** | Node.js        | 3000 | WebSocket real-time notifications      |

## Directory Structure

```
services/
├── frontend/
│   ├── src/
│   │   ├── index.html
│   │   └── app.js
│   └── nginx.conf
│
├── api-gateway/
│   ├── src/
│   │   └── index.js
│   └── package.json
│
├── auth-service/
│   ├── src/
│   │   └── app.py
│   ├── requirements.txt
│   └── healthcheck.sh
│
├── product-service/
│   ├── src/
│   │   └── index.js
│   └── package.json
│
├── order-service/
│   ├── src/
│   │   └── app.py
│   ├── requirements.txt
│   └── healthcheck.sh
│
└── notification-service/
    ├── src/
    │   └── index.js
    └── package.json
```

## Your Tasks

### 1. Create Dockerfiles

For each service, create a `Dockerfile` that:

- ✅ Uses multi-stage builds (where applicable)
- ✅ Runs as non-root user
- ✅ Includes health checks
- ✅ Optimizes layer caching
- ✅ Includes proper labels

## Environment Variables

Each service expects these environment variables:

### api-gateway

```
PORT=3000
JWT_SECRET=your-secret-key
REDIS_HOST=redis
REDIS_PASSWORD=your-password
AUTH_SERVICE_URL=http://auth-service:5000
PRODUCT_SERVICE_URL=http://product-service:3000
ORDER_SERVICE_URL=http://order-service:5000
NOTIFICATION_SERVICE_URL=http://notification-service:3000
```

### auth-service

```
DB_HOST=mariadb
DB_PORT=3306
DB_USER=appuser
DB_PASSWORD=your-password
DB_NAME=shopstream
JWT_SECRET=your-secret-key
```

### product-service

```
DB_HOST=mariadb
DB_PORT=3306
DB_USER=appuser
DB_PASSWORD=your-password
DB_NAME=shopstream
ELASTICSEARCH_URL=http://elasticsearch:9200
```

### order-service

```
DB_HOST=mariadb
DB_PORT=3306
DB_USER=appuser
DB_PASSWORD=your-password
DB_NAME=shopstream
RABBITMQ_HOST=rabbitmq
RABBITMQ_USER=guest
RABBITMQ_PASSWORD=your-password
PRODUCT_SERVICE_URL=http://product-service:3000
```

### notification-service

```
PORT=3000
RABBITMQ_HOST=rabbitmq
RABBITMQ_USER=guest
RABBITMQ_PASSWORD=your-password
```

## Building Images

Once you create the Dockerfiles, build them with:

```bash
# Build all images
docker build -t shopstream/frontend:1.0.0 ./frontend/
docker build -t shopstream/api-gateway:1.0.0 ./api-gateway/
docker build -t shopstream/auth-service:1.0.0 ./auth-service/
docker build -t shopstream/product-service:1.0.0 ./product-service/
docker build -t shopstream/order-service:1.0.0 ./order-service/
docker build -t shopstream/notification-service:1.0.0 ./notification-service/
```

## Hints

1. **Layer Caching**: Copy package.json/requirements.txt before source code
2. **Multi-stage**: Use builder pattern to keep images small
3. **Non-root**: Always run as non-root user for security
4. **Health checks**: Make sure health endpoints work before Docker health check
5. **Labels**: Add metadata for better image management
