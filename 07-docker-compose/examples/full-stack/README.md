# Full Stack Application

A complete full-stack application demonstrating real-world Docker Compose usage with:

- **Nginx** - Reverse proxy and static files
- **Node.js API** - Backend REST API
- **MariaDB** - Database
- **Redis** - Caching layer
- **Adminer** - Database management

## Architecture

```text
                                   ┌─────────────────┐
                              ┌───►│   Static Files  │
                              │    └─────────────────┘
┌──────────┐    ┌─────────┐   │    ┌─────────────────┐
│  Client  │───►│  Nginx  │───┼───►│    Node.js      │
└──────────┘    │ (Proxy) │   │    │      API        │
                └─────────┘   │    └────────┬────────┘
                :80           │             │
                              │    ┌────────┴────────┐
                              │    │                 │
                              │ ┌──▼───┐       ┌─────▼─────┐
                              │ │Redis │       │  MariaDB  │
                              │ │Cache │       │  Database │
                              │ └──────┘       └───────────┘
                              │
                              │    ┌─────────────────┐
                              └───►│    Adminer      │
                                   │   (DB Admin)    │
                                   └─────────────────┘
                                   :8081
```

## Quick Start

```bash
# 1. Copy environment file
cp .env.example .env

# 2. Start all services
docker-compose up -d --build

# 3. Wait for services to be healthy
docker-compose ps

# 4. Access the application
open http://localhost
```

## Services

| Service | Port            | Description                  |
| ------- | --------------- | ---------------------------- |
| nginx   | 80              | Reverse proxy + static files |
| api     | 3000 (internal) | Node.js REST API             |
| db      | 3306 (internal) | MariaDB database             |
| redis   | 6379 (internal) | Redis cache                  |
| adminer | 8081            | Database admin UI            |

## API Endpoints

| Endpoint      | Method | Description        |
| ------------- | ------ | ------------------ |
| `/api/health` | GET    | Health check       |
| `/api/users`  | GET    | List all users     |
| `/api/users`  | POST   | Create user        |
| `/api/stats`  | GET    | Redis cached stats |

## Development

```bash
# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f api

# Restart a service
docker-compose restart api

# Rebuild after code changes
docker-compose up -d --build api

# Access database shell
docker-compose exec db mysql -u root -p

# Access Redis CLI
docker-compose exec redis redis-cli
```

## Cleanup

```bash
# Stop services
docker-compose down

# Stop and remove volumes (full reset)
docker-compose down -v
```
