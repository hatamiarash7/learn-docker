# Web Stack Example

A simple web application stack demonstrating Docker Swarm features.

## Architecture

```
                    ┌─────────────────┐
                    │   Load Balancer │
                    │   (Ingress)     │
                    └────────┬────────┘
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
          ▼                  ▼                  ▼
    ┌──────────┐       ┌──────────┐       ┌──────────┐
    │   Web    │       │   Web    │       │   Web    │
    │ Replica 1│       │ Replica 2│       │ Replica 3│
    └────┬─────┘       └────┬─────┘       └────┬─────┘
         │                  │                  │
         └──────────────────┼──────────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │    Redis     │
                    └──────────────┘
```

## Prerequisites

Initialize swarm if not already done:

```bash
docker swarm init
```

## Deploy

```bash
docker stack deploy -c docker-stack.yml webstack
```

## Verify

```bash
# List stacks
docker stack ls

# List stack services
docker stack services webstack

# List all tasks
docker stack ps webstack

# View web service logs
docker service logs -f webstack_web
```

## Access

- **Web Application**: <http://localhost>
- **Visualizer**: <http://localhost:8080> (shows swarm state)

## Scale

```bash
# Scale web service
docker service scale webstack_web=5

# Verify
docker service ps webstack_web
```

## Update

```bash
# Update web image
docker service update --image nginx:1.25-alpine webstack_web

# Watch the rolling update
watch docker service ps webstack_web
```

## Rollback

```bash
docker service rollback webstack_web
```

## Remove

```bash
docker stack rm webstack
```

## Features Demonstrated

- ✅ Service replicas
- ✅ Overlay networking
- ✅ Health checks
- ✅ Resource limits
- ✅ Rolling updates
- ✅ Placement constraints
- ✅ Persistent volumes
