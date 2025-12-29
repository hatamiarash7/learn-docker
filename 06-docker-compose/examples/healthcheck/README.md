# Health Checks Example

This example demonstrates proper health checks and dependency management.

## Why Health Checks?

- Ensure services are actually ready (not just running)
- Docker can restart unhealthy containers
- Proper startup order with `depends_on: condition: service_healthy`

## Services

| Service | Health Check               | Start Condition    |
| ------- | -------------------------- | ------------------ |
| db      | MariaDB healthcheck script | -                  |
| redis   | `redis-cli ping`           | -                  |
| api     | HTTP `/health` endpoint    | db + redis healthy |
| web     | HTTP check                 | api healthy        |

## Startup Order

```text
1. db (MariaDB) starts
2. redis starts
3. Wait for db AND redis to be healthy
4. api starts
5. Wait for api to be healthy
6. web starts
```

## Usage

```bash
# Start and watch the startup process
docker-compose up

# In another terminal, watch health status
watch -n 1 docker-compose ps

# Check detailed health info
docker inspect healthcheck-api-1 --format='{{json .State.Health}}' | jq
```

## Health Check States

| State       | Description          |
| ----------- | -------------------- |
| `starting`  | Initial grace period |
| `healthy`   | Health check passing |
| `unhealthy` | Health check failing |

## Cleanup

```bash
docker-compose down -v
```
