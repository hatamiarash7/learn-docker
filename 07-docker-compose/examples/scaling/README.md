# Scaling with Docker Compose

This example demonstrates horizontal scaling with a load balancer.

## Architecture

```text
                        ┌─────────────────┐
                   ┌───►│   Web Server 1  │
                   │    └─────────────────┘
┌──────────────┐   │    ┌─────────────────┐
│ Load Balancer│───┼───►│   Web Server 2  │
│   (Nginx)    │   │    └─────────────────┘
└──────────────┘   │    ┌─────────────────┐
     :8080         └───►│   Web Server 3  │
                        └─────────────────┘
```

## Usage

```bash
# Start with 3 web instances
docker-compose up -d --scale web=3

# Check running containers
docker-compose ps

# Test load balancing
for i in {1..10}; do curl -s http://localhost:8080 | grep Hostname; done

# Scale up to 5 instances
docker-compose up -d --scale web=5

# Scale down to 2 instances
docker-compose up -d --scale web=2

# Stop
docker-compose down
```

## Key Points

1. **No fixed ports** - Web containers don't expose specific host ports
2. **No container_name** - Allows multiple instances
3. **Load balancer** - Nginx distributes traffic across all web instances
4. **Docker DNS** - Nginx resolves "web" to all container IPs

## Load Balancing Methods

Nginx supports various load balancing methods:

- `round-robin` (default) - Distributes evenly
- `least_conn` - Routes to least busy server
- `ip_hash` - Routes based on client IP

See `nginx.conf` for configuration.
