# Basic Swarm Service

The simplest Docker Swarm example - deploying a service with replicas.

## Prerequisites

Initialize swarm mode:

```bash
docker swarm init
```

## Quick Start

```bash
# Create a service with 3 replicas
docker service create --name web --replicas 3 -p 80:80 nginx:alpine

# List services
docker service ls

# View tasks (containers)
docker service ps web

# Scale the service
docker service scale web=5

# View logs
docker service logs -f web

# Remove service
docker service rm web
```

## Commands Explained

| Command | Description |
|---------|-------------|
| `docker service create` | Create a new service |
| `--name web` | Service name |
| `--replicas 3` | Run 3 instances |
| `-p 80:80` | Publish port 80 |
| `docker service ls` | List all services |
| `docker service ps <name>` | List service tasks |
| `docker service scale` | Change replica count |
| `docker service logs` | View service logs |
| `docker service rm` | Remove service |

## Test Load Balancing

```bash
# Make multiple requests
for i in {1..10}; do
    curl -s http://localhost 2>/dev/null | grep -o 'nginx'
    echo " - Request $i"
done
```

## Clean Up

```bash
docker service rm web
```
