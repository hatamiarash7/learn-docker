# Multi-Service Networking Example

This example demonstrates a complete multi-service application with proper networking.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Host                                 │
│                                                              │
│    :8080 ────► Web (Nginx)                                  │
│    :3000 ────► API (Node.js)                                │
│    :8081 ────► Adminer (DB UI)                              │
│                                                              │
│    ┌─────────────────────────────────────────────────────┐  │
│    │              frontend network                        │  │
│    │   ┌─────────┐        ┌─────────┐                    │  │
│    │   │   web   │◄──────►│   api   │                    │  │
│    │   └─────────┘        └────┬────┘                    │  │
│    └───────────────────────────┼─────────────────────────┘  │
│                                │                             │
│    ┌───────────────────────────┼─────────────────────────┐  │
│    │              backend network                         │  │
│    │                      ┌────┴────┐      ┌─────────┐   │  │
│    │                      │   api   │◄────►│   db    │   │  │
│    │                      └─────────┘      │ (Redis) │   │  │
│    │   ┌─────────┐                         └─────────┘   │  │
│    │   │ adminer │◄───────────────────────────────┘      │  │
│    │   └─────────┘                                       │  │
│    └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| web | 8080 | Nginx web server |
| api | 3000 | Node.js API |
| db | - | Redis database (internal only) |
| adminer | 8081 | Database admin UI |

## Usage

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Test web
curl http://localhost:8080

# Test API
curl http://localhost:3000

# Access Adminer
open http://localhost:8081

# Stop all services
docker-compose down
```

## Network Isolation

- `web` can only access `api`
- `api` can access both `web` and `db`
- `db` is only accessible from the backend network
- `adminer` can access `db` for administration
