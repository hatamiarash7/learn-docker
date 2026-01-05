# 🐝 Docker Swarm Mode

Master Docker's native orchestration for deploying and managing containerized applications at scale across multiple nodes.

- [🐝 Docker Swarm Mode](#-docker-swarm-mode)
  - [What is Docker Swarm?](#what-is-docker-swarm)
    - [Why Docker Swarm?](#why-docker-swarm)
    - [Swarm vs Kubernetes](#swarm-vs-kubernetes)
  - [Swarm Architecture](#swarm-architecture)
    - [Core Concepts](#core-concepts)
    - [Key Components](#key-components)
    - [Manager Node Responsibilities](#manager-node-responsibilities)
    - [Recommended Manager Count](#recommended-manager-count)
  - [Setting Up a Swarm](#setting-up-a-swarm)
    - [Initialize Swarm (Single Node)](#initialize-swarm-single-node)
    - [Join Nodes to Swarm](#join-nodes-to-swarm)
    - [Swarm Information](#swarm-information)
  - [Nodes Management](#nodes-management)
    - [Listing Nodes](#listing-nodes)
    - [Node Information](#node-information)
    - [Managing Node Availability](#managing-node-availability)
    - [Node Roles](#node-roles)
    - [Node Labels](#node-labels)
    - [Remove Node](#remove-node)
  - [Services](#services)
    - [Creating Services](#creating-services)
    - [Listing Services](#listing-services)
    - [Updating Services](#updating-services)
    - [Removing Services](#removing-services)
    - [Service Modes](#service-modes)
  - [Stacks](#stacks)
    - [Stack File Example](#stack-file-example)
    - [Deploying Stacks](#deploying-stacks)
    - [Stack vs Compose](#stack-vs-compose)
  - [Networking in Swarm](#networking-in-swarm)
    - [Network Types](#network-types)
    - [Overlay Networks](#overlay-networks)
    - [Service Discovery](#service-discovery)
    - [Ingress Routing Mesh](#ingress-routing-mesh)
    - [Bypass Routing Mesh](#bypass-routing-mesh)
  - [Secrets Management](#secrets-management)
    - [How Secrets Work](#how-secrets-work)
    - [Creating Secrets](#creating-secrets)
    - [Managing Secrets](#managing-secrets)
    - [Using Secrets in Services](#using-secrets-in-services)
    - [Using Secrets in Stacks](#using-secrets-in-stacks)
  - [Configs Management](#configs-management)
    - [Creating Configs](#creating-configs)
    - [Managing Configs](#managing-configs)
    - [Using Configs in Services](#using-configs-in-services)
    - [Using Configs in Stacks](#using-configs-in-stacks)
  - [Rolling Updates \& Rollbacks](#rolling-updates--rollbacks)
    - [Update Configuration](#update-configuration)
    - [Update Parameters Explained](#update-parameters-explained)
    - [Monitor Update Progress](#monitor-update-progress)
    - [Rollback](#rollback)
    - [Stack Updates](#stack-updates)
  - [Scaling Applications](#scaling-applications)
    - [Scale Services](#scale-services)
    - [Scaling in Stack Files](#scaling-in-stack-files)
    - [Auto-Scaling (Manual Implementation)](#auto-scaling-manual-implementation)
  - [Health Checks \& Self-Healing](#health-checks--self-healing)
    - [Health Check Configuration](#health-check-configuration)
    - [Health Check in Dockerfile](#health-check-in-dockerfile)
    - [Health Check in Stack File](#health-check-in-stack-file)
    - [Self-Healing Behavior](#self-healing-behavior)
  - [Placement Constraints](#placement-constraints)
    - [Built-in Constraints](#built-in-constraints)
    - [Label-Based Constraints](#label-based-constraints)
    - [Placement Preferences (Soft Constraints)](#placement-preferences-soft-constraints)
    - [Stack File Placement](#stack-file-placement)
  - [Monitoring \& Logging](#monitoring--logging)
    - [Built-in Monitoring](#built-in-monitoring)
    - [Centralized Logging](#centralized-logging)
    - [Monitoring Stack Example](#monitoring-stack-example)
  - [Production Best Practices](#production-best-practices)
    - [1. Manager Node Configuration](#1-manager-node-configuration)
    - [2. Network Security](#2-network-security)
    - [3. Resource Limits](#3-resource-limits)
    - [4. Update Strategy](#4-update-strategy)
    - [5. Health Checks](#5-health-checks)
    - [6. Secrets Management](#6-secrets-management)
    - [7. Logging](#7-logging)
    - [8. Backup Strategy](#8-backup-strategy)
  - [Exercises](#exercises)
    - [🎯 Exercise 1: Initialize and Explore Swarm](#-exercise-1-initialize-and-explore-swarm)
    - [🎯 Exercise 2: Deploy Your First Service](#-exercise-2-deploy-your-first-service)
    - [🎯 Exercise 3: Rolling Update](#-exercise-3-rolling-update)
    - [🎯 Exercise 4: Secrets Management](#-exercise-4-secrets-management)
    - [🎯 Exercise 5: Deploy a Stack](#-exercise-5-deploy-a-stack)
    - [🎯 Exercise 6: Node Labels and Constraints](#-exercise-6-node-labels-and-constraints)
    - [🎯 Exercise 7: Overlay Networking](#-exercise-7-overlay-networking)
    - [🎯 Exercise 8: Full Production-Like Deployment](#-exercise-8-full-production-like-deployment)
  - [📁 Examples Directory](#-examples-directory)
  - [📝 Quick Reference](#-quick-reference)
    - [Swarm Commands](#swarm-commands)
    - [Node Commands](#node-commands)
    - [Service Commands](#service-commands)
    - [Stack Commands](#stack-commands)
    - [Secret \& Config Commands](#secret--config-commands)
  - [✅ Checklist](#-checklist)

## What is Docker Swarm?

Docker Swarm is Docker's **native container orchestration** solution. It turns a group of Docker hosts into a single, virtual Docker host.

### Why Docker Swarm?

| Feature               | Benefit                                  |
| --------------------- | ---------------------------------------- |
| **Native to Docker**  | No additional tools needed               |
| **Easy to learn**     | Uses familiar Docker commands            |
| **Built-in security** | TLS encryption, secrets management       |
| **Declarative model** | Define desired state, Swarm maintains it |
| **Load balancing**    | Automatic service discovery and routing  |
| **Rolling updates**   | Zero-downtime deployments                |
| **Self-healing**      | Automatically replaces failed containers |

### Swarm vs Kubernetes

| Aspect         | Docker Swarm      | Kubernetes       |
| -------------- | ----------------- | ---------------- |
| Complexity     | Simple            | Complex          |
| Learning curve | Short             | Steep            |
| Setup time     | Minutes           | Hours/Days       |
| Features       | Essential         | Extensive        |
| Community      | Smaller           | Larger           |
| Best for       | Small-medium apps | Large enterprise |

## Swarm Architecture

### Core Concepts

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                             DOCKER SWARM CLUSTER                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│    ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐            │
│    │  MANAGER NODE   │  │  MANAGER NODE   │  │  MANAGER NODE   │            │
│    │   (Leader)      │  │   (Follower)    │  │   (Follower)    │            │
│    │                 │  │                 │  │                 │            │
│    │ • API Server    │  │ • API Server    │  │ • API Server    │            │
│    │ • Orchestrator  │  │ • Raft Store    │  │ • Raft Store    │            │
│    │ • Scheduler     │  │                 │  │                 │            │
│    │ • Allocator     │  │                 │  │                 │            │
│    │ • Dispatcher    │◄─┤ Raft Consensus  ├──►                 │            │
│    │ • Raft Store    │  │                 │  │                 │            │
│    └────────┬────────┘  └─────────────────┘  └─────────────────┘            │
│             │                                                               │
│             │ Assigns tasks to workers                                      │
│             ▼                                                               │
│    ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐            │
│    │  WORKER NODE    │  │  WORKER NODE    │  │  WORKER NODE    │            │
│    │                 │  │                 │  │                 │            │
│    │ ┌─────┐ ┌─────┐ │  │ ┌─────┐ ┌─────┐ │  │ ┌─────┐ ┌─────┐ │            │
│    │ │Task1│ │Task2│ │  │ │Task3│ │Task4│ │  │ │Task5│ │Task6│ │            │
│    │ └─────┘ └─────┘ │  │ └─────┘ └─────┘ │  │ └─────┘ └─────┘ │            │
│    │                 │  │                 │  │                 │            │
│    └─────────────────┘  └─────────────────┘  └─────────────────┘            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key Components

| Component   | Description                                        |
| ----------- | -------------------------------------------------- |
| **Node**    | A Docker host participating in the swarm           |
| **Manager** | Manages cluster state and schedules tasks          |
| **Worker**  | Executes containers (tasks)                        |
| **Service** | Definition of tasks to run (replicas, image, etc.) |
| **Task**    | A single container running as part of a service    |
| **Stack**   | Collection of services that make up an application |

### Manager Node Responsibilities

1. **Raft Consensus**: Maintains consistent cluster state
2. **Orchestration**: Manages desired state
3. **Scheduling**: Assigns tasks to nodes
4. **API Server**: Accepts commands from CLI
5. **Dispatcher**: Sends tasks to workers

### Recommended Manager Count

| Managers | Fault Tolerance | Notes               |
| -------- | --------------- | ------------------- |
| 1        | None            | Development only    |
| 3        | 1 failure       | Recommended minimum |
| 5        | 2 failures      | High availability   |
| 7        | 3 failures      | Maximum recommended |

> [!NOTE]
> Always use an **odd number** of managers for Raft consensus.

## Setting Up a Swarm

### Initialize Swarm (Single Node)

```bash
# Initialize swarm on current machine
docker swarm init

# With specific advertise address (for multi-NIC systems)
docker swarm init --advertise-addr 192.168.1.100

# View join tokens
docker swarm join-token manager
docker swarm join-token worker
```

### Join Nodes to Swarm

```bash
# Join as worker (run on worker nodes)
docker swarm join --token SWMTKN-1-xxx 192.168.1.100:2377

# Join as manager (run on manager nodes)
docker swarm join --token SWMTKN-1-yyy 192.168.1.100:2377
```

### Swarm Information

```bash
# View swarm info
docker info | grep -A 20 Swarm

# Detailed swarm info
docker node ls

# Leave swarm (on any node)
docker swarm leave

# Force leave (managers)
docker swarm leave --force
```

## Nodes Management

### Listing Nodes

```bash
# List all nodes
docker node ls

# Output example:
# ID                            HOSTNAME   STATUS    AVAILABILITY   MANAGER STATUS
# abc123 *                      node1      Ready     Active         Leader
# def456                        node2      Ready     Active         Reachable
# ghi789                        node3      Ready     Active         
```

### Node Information

```bash
# Detailed node info
docker node inspect <node-name>

# Readable format
docker node inspect --pretty <node-name>

# Node tasks
docker node ps <node-name>
```

### Managing Node Availability

```bash
# Drain node (gracefully remove containers)
docker node update --availability drain <node-name>

# Pause node (no new tasks, keep existing)
docker node update --availability pause <node-name>

# Activate node
docker node update --availability active <node-name>
```

### Node Roles

```bash
# Promote worker to manager
docker node promote <node-name>

# Demote manager to worker
docker node demote <node-name>
```

### Node Labels

```bash
# Add label to node
docker node update --label-add env=production node1
docker node update --label-add disk=ssd node2

# Remove label
docker node update --label-rm env node1

# View labels
docker node inspect --pretty node1 | grep Labels -A 10
```

### Remove Node

```bash
# On the node being removed:
docker swarm leave

# On manager, remove the node:
docker node rm <node-name>

# Force remove
docker node rm --force <node-name>
```

## Services

Services are the primary abstraction for deploying applications in Swarm.

### Creating Services

```bash
# Basic service
docker service create --name web nginx:alpine

# With replicas
docker service create --name web --replicas 3 nginx:alpine

# With port publishing
docker service create --name web --replicas 3 -p 80:80 nginx:alpine

# With environment variables
docker service create --name web \
    --replicas 3 \
    -e "DEBUG=true" \
    -e "DB_HOST=db" \
    nginx:alpine

# With volume mount
docker service create --name db \
    --mount type=volume,source=db-data,target=/var/lib/mysql \
    mariadb:latest

# With resource limits
docker service create --name web \
    --replicas 3 \
    --limit-cpu 0.5 \
    --limit-memory 256M \
    --reserve-cpu 0.25 \
    --reserve-memory 128M \
    nginx:alpine
```

### Listing Services

```bash
# List all services
docker service ls

# Detailed service info
docker service inspect <service-name>
docker service inspect --pretty <service-name>

# List service tasks (containers)
docker service ps <service-name>

# View service logs
docker service logs <service-name>
docker service logs -f <service-name>  # Follow
docker service logs --tail 100 <service-name>
```

### Updating Services

```bash
# Update image
docker service update --image nginx:1.25 web

# Update replicas
docker service update --replicas 5 web

# Add environment variable
docker service update --env-add NEW_VAR=value web

# Remove environment variable
docker service update --env-rm OLD_VAR web

# Update port
docker service update --publish-add 8080:80 web
docker service update --publish-rm 80:80 web

# Update resources
docker service update --limit-cpu 1.0 --limit-memory 512M web

# Multiple updates at once
docker service update \
    --image nginx:1.25 \
    --replicas 5 \
    --env-add VERSION=2.0 \
    web
```

### Removing Services

```bash
# Remove a service
docker service rm <service-name>

# Remove multiple services
docker service rm web api db
```

### Service Modes

```bash
# Replicated mode (default) - specific number of replicas
docker service create --name web --replicas 3 nginx:alpine

# Global mode - one task per node
docker service create --name monitoring --mode global prometheus/node-exporter
```

## Stacks

Stacks deploy multiple services from a single compose file.

### Stack File Example

```yaml
# docker-stack.yml
version: "3.9"

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
    networks:
      - frontend

  api:
    image: my-api:latest
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
    networks:
      - frontend
      - backend
    secrets:
      - db_password

  db:
    image: mariadb:latest
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
    volumes:
      - db-data:/var/lib/mysql
    networks:
      - backend
    secrets:
      - db_password

networks:
  frontend:
  backend:

volumes:
  db-data:

secrets:
  db_password:
    external: true
```

### Deploying Stacks

```bash
# Deploy a stack
docker stack deploy -c docker-stack.yml myapp

# List stacks
docker stack ls

# List stack services
docker stack services myapp

# List stack tasks
docker stack ps myapp

# Remove stack
docker stack rm myapp
```

### Stack vs Compose

| Feature  | Docker Compose        | Docker Stack          |
| -------- | --------------------- | --------------------- |
| Command  | `docker compose`      | `docker stack`        |
| Scope    | Single host           | Swarm cluster         |
| `build`  | Supported             | Not supported         |
| `deploy` | Ignored               | Used                  |
| Networks | Created automatically | Created automatically |

## Networking in Swarm

### Network Types

| Type        | Description            | Use Case                         |
| ----------- | ---------------------- | -------------------------------- |
| **overlay** | Multi-host networking  | Service-to-service communication |
| **ingress** | Built-in load balancer | External access to services      |
| **bridge**  | Single host            | Local development                |

### Overlay Networks

```bash
# Create overlay network
docker network create --driver overlay --attachable my-network

# Create encrypted overlay network
docker network create --driver overlay --opt encrypted my-secure-network

# List networks
docker network ls

# Inspect network
docker network inspect my-network
```

### Service Discovery

Services automatically get DNS names for discovery:

```bash
# Create network
docker network create --driver overlay app-net

# Create services
docker service create --name db --network app-net mariadb:latest
docker service create --name api --network app-net my-api

# From 'api' service, connect using hostname 'db'
# The DNS name 'db' resolves to the service's virtual IP
```

### Ingress Routing Mesh

The **routing mesh** automatically routes external traffic to services:

```text
┌─────────────────────────────────────────────────────────────┐
│                     EXTERNAL REQUEST                        │
│                    http://any-node:80                       │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    INGRESS NETWORK                          │
│              (Built-in Load Balancer)                       │
│                                                             │
│    ┌─────────┐      ┌─────────┐      ┌─────────┐            │
│    │ Node 1  │      │ Node 2  │      │ Node 3  │            │
│    │ :80     │      │ :80     │      │ :80     │            │
│    └────┬────┘      └────┬────┘      └────┬────┘            │
└─────────┼────────────────┼────────────────┼─────────────────┘
          │                │                │
          ▼                ▼                ▼
     ┌─────────┐      ┌─────────┐      ┌─────────┐
     │ Task 1  │      │ Task 2  │      │ Task 3  │
     │ (web)   │      │ (web)   │      │ (web)   │
     └─────────┘      └─────────┘      └─────────┘
```

> [!NOTE]
> Request to **any node** on port 80 is routed to **any healthy task**.

### Bypass Routing Mesh

```bash
# Host mode - container port binds directly to host
docker service create --name web \
    --publish mode=host,target=80,published=80 \
    nginx:alpine
```

## Secrets Management

Secrets securely store sensitive data like passwords, API keys, and certificates.

### How Secrets Work

```text
┌──────────────────────────────────────────────────┐
│                 MANAGER NODE                     │
│                                                  │
│  ┌─────────────────────────────────────────────┐ │
│  │              RAFT LOG (Encrypted)           │ │
│  │     ┌─────────┐ ┌─────────┐ ┌─────────┐     │ │
│  │     │Secret 1 │ │Secret 2 │ │Secret 3 │     │ │
│  │     └─────────┘ └─────────┘ └─────────┘     │ │
│  └─────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────┘
                         │
                         │ TLS Encrypted
                         ▼
┌───────────────────────────────────────────v───────┐
│                  WORKER NODE                      │
│                                                   │
│  ┌──────────────────────────────────────────────┐ │
│  │              CONTAINER                       │ │
│  │                                              │ │
│  │  /run/secrets/db_password  (in-memory tmpfs) │ │
│  │  /run/secrets/api_key      (in-memory tmpfs) │ │
│  │                                              │ │
│  └──────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────┘
```

### Creating Secrets

```bash
# Create from string
echo "mysecretpassword" | docker secret create db_password -

# Create from file
docker secret create ssl_cert ./certificate.pem

# Create with labels
echo "api-key-value" | docker secret create --label env=prod api_key -
```

### Managing Secrets

```bash
# List secrets
docker secret ls

# Inspect secret (shows metadata, not value)
docker secret inspect db_password

# Remove secret
docker secret rm db_password
```

### Using Secrets in Services

```bash
# Create service with secret
docker service create --name db \
    --secret db_password \
    -e MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_password \
    mariadb:latest

# Multiple secrets
docker service create --name api \
    --secret db_password \
    --secret api_key \
    my-api

# Custom secret path and permissions
docker service create --name web \
    --secret source=ssl_cert,target=/etc/ssl/private/cert.pem,mode=0400 \
    nginx:alpine
```

### Using Secrets in Stacks

```yaml
# docker-stack.yml
version: "3.9"

services:
  db:
    image: mariadb:latest
    secrets:
      - db_password
      - db_root_password
    environment:
      MARIADB_ROOT_PASSWORD_FILE: /run/secrets/db_root_password
      MARIADB_PASSWORD_FILE: /run/secrets/db_password

  api:
    image: my-api
    secrets:
      - source: api_key
        target: /app/secrets/api.key
        mode: 0400

secrets:
  db_password:
    external: true  # Must be created before deployment
  db_root_password:
    file: ./secrets/root_password.txt  # Created during deployment
  api_key:
    external: true
```

## Configs Management

Configs store non-sensitive configuration data that can be shared between services.

### Creating Configs

```bash
# Create from file
docker config create nginx_conf ./nginx.conf

# Create from stdin
echo "LOG_LEVEL=debug" | docker config create app_config -
```

### Managing Configs

```bash
# List configs
docker config ls

# Inspect config (shows content!)
docker config inspect nginx_conf

# Remove config
docker config rm nginx_conf
```

### Using Configs in Services

```bash
# Mount config in service
docker service create --name web \
    --config source=nginx_conf,target=/etc/nginx/nginx.conf \
    nginx:alpine

# Multiple configs
docker service create --name app \
    --config app_config \
    --config source=ssl_conf,target=/etc/ssl/conf,mode=0600 \
    my-app
```

### Using Configs in Stacks

```yaml
version: "3.9"

services:
  web:
    image: nginx:alpine
    configs:
      - source: nginx_config
        target: /etc/nginx/conf.d/default.conf

configs:
  nginx_config:
    file: ./nginx/default.conf
```

## Rolling Updates & Rollbacks

### Update Configuration

```bash
# Update with specific parameters
docker service update \
    --image nginx:1.25 \
    --update-parallelism 2 \      # Update 2 tasks at a time
    --update-delay 10s \          # Wait 10s between batches
    --update-failure-action pause \  # Pause on failure
    --update-max-failure-ratio 0.25 \  # Allow 25% failures
    --update-order start-first \  # Start new before stopping old
    web
```

### Update Parameters Explained

| Parameter           | Description                                 | Default    |
| ------------------- | ------------------------------------------- | ---------- |
| `parallelism`       | Tasks to update simultaneously              | 1          |
| `delay`             | Time between task updates                   | 0s         |
| `failure-action`    | Action on failure (pause/continue/rollback) | pause      |
| `max-failure-ratio` | Failure threshold (0.0-1.0)                 | 0          |
| `order`             | Update order (stop-first/start-first)       | stop-first |
| `monitor`           | Time to monitor after update                | 5s         |

### Monitor Update Progress

```bash
# Watch update progress
docker service ps web

# Detailed update status
docker service inspect --pretty web

# View logs during update
docker service logs -f web
```

### Rollback

```bash
# Automatic rollback (if update fails and failure-action=rollback)
docker service update --update-failure-action rollback --image bad:image web

# Manual rollback
docker service rollback web

# Rollback configuration
docker service update \
    --rollback-parallelism 2 \
    --rollback-delay 5s \
    --rollback-failure-action pause \
    web
```

### Stack Updates

```bash
# Update stack (re-deploy with new config)
docker stack deploy -c docker-stack.yml myapp

# Only services with changes are updated
```

## Scaling Applications

### Scale Services

```bash
# Scale single service
docker service scale web=5

# Scale multiple services
docker service scale web=5 api=3 worker=10

# Using update command
docker service update --replicas 5 web
```

### Scaling in Stack Files

```yaml
services:
  web:
    image: nginx:alpine
    deploy:
      replicas: 5
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
        reservations:
          cpus: '0.25'
          memory: 64M
```

### Auto-Scaling (Manual Implementation)

```bash
#!/bin/bash
# Simple auto-scaler based on CPU usage

SERVICE="web"
MIN_REPLICAS=2
MAX_REPLICAS=10
SCALE_UP_THRESHOLD=80
SCALE_DOWN_THRESHOLD=20

while true; do
    # Get average CPU usage (simplified)
    CPU_USAGE=$(docker stats --no-stream --format "{{.CPUPerc}}" \
        $(docker service ps -q $SERVICE) 2>/dev/null | \
        sed 's/%//' | awk '{sum+=$1} END {print sum/NR}')
    
    CURRENT=$(docker service ls --filter name=$SERVICE --format "{{.Replicas}}" | cut -d'/' -f1)
    
    if (( $(echo "$CPU_USAGE > $SCALE_UP_THRESHOLD" | bc -l) )); then
        NEW=$((CURRENT + 1))
        if [ $NEW -le $MAX_REPLICAS ]; then
            docker service scale $SERVICE=$NEW
        fi
    elif (( $(echo "$CPU_USAGE < $SCALE_DOWN_THRESHOLD" | bc -l) )); then
        NEW=$((CURRENT - 1))
        if [ $NEW -ge $MIN_REPLICAS ]; then
            docker service scale $SERVICE=$NEW
        fi
    fi
    
    sleep 30
done
```

## Health Checks & Self-Healing

### Health Check Configuration

```bash
# Create service with health check
docker service create --name web \
    --health-cmd "curl -f http://localhost/ || exit 1" \
    --health-interval 30s \
    --health-timeout 10s \
    --health-retries 3 \
    --health-start-period 60s \
    nginx:alpine
```

### Health Check in Dockerfile

```dockerfile
FROM nginx:alpine

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1
```

### Health Check in Stack File

```yaml
services:
  web:
    image: nginx:alpine
    deploy:
      replicas: 3
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

### Self-Healing Behavior

When a health check fails:

1. Container marked as **unhealthy**
2. Swarm schedules a **new task**
3. New container starts
4. Old container stopped after new is healthy
5. Service maintains **desired replica count**

```text
Timeline:
─────────────────────────────────────────────────────────
  Task 1: [  Running  ]───[Unhealthy]───[Stopped]
  Task 2:                      [Starting]───[Running]───►
─────────────────────────────────────────────────────────
                               ↑
                        New task scheduled
```

## Placement Constraints

Control where tasks are scheduled.

### Built-in Constraints

```bash
# Only on manager nodes
docker service create --name admin \
    --constraint 'node.role==manager' \
    admin-panel

# Only on worker nodes
docker service create --name web \
    --constraint 'node.role==worker' \
    nginx:alpine

# On specific node
docker service create --name db \
    --constraint 'node.hostname==db-server' \
    mariadb:latest

# By node ID
docker service create --name app \
    --constraint 'node.id==abc123...' \
    my-app
```

### Label-Based Constraints

```bash
# Add labels to nodes
docker node update --label-add env=production node1
docker node update --label-add disk=ssd node2
docker node update --label-add region=us-east node3

# Deploy to production nodes only
docker service create --name api \
    --constraint 'node.labels.env==production' \
    my-api

# Deploy to SSD nodes
docker service create --name db \
    --constraint 'node.labels.disk==ssd' \
    mariadb:latest

# Multiple constraints (AND logic)
docker service create --name critical-app \
    --constraint 'node.labels.env==production' \
    --constraint 'node.labels.disk==ssd' \
    critical-app
```

### Placement Preferences (Soft Constraints)

```bash
# Spread across availability zones
docker service create --name web \
    --replicas 6 \
    --placement-pref 'spread=node.labels.zone' \
    nginx:alpine

# If you have 3 zones, each gets 2 replicas
```

### Stack File Placement

```yaml
services:
  web:
    image: nginx:alpine
    deploy:
      replicas: 6
      placement:
        constraints:
          - node.role == worker
          - node.labels.env == production
        preferences:
          - spread: node.labels.zone
```

## Monitoring & Logging

### Built-in Monitoring

```bash
# Service status
docker service ls

# Task status
docker service ps <service>

# Node status
docker node ls

# Real-time stats
docker stats $(docker ps -q)
```

### Centralized Logging

```yaml
# docker-stack.yml with logging
services:
  web:
    image: nginx:alpine
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service,environment"

  # Or use external logging drivers
  api:
    image: my-api
    logging:
      driver: "fluentd"
      options:
        fluentd-address: "localhost:24224"
        tag: "docker.{{.Name}}"
```

### Monitoring Stack Example

```yaml
# monitoring-stack.yml
version: "3.8"

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - prometheus-data:/prometheus
    configs:
      - source: prometheus_config
        target: /etc/prometheus/prometheus.yml
    deploy:
      placement:
        constraints:
          - node.role == manager

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
    deploy:
      replicas: 1

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    deploy:
      mode: global  # One per node

  node-exporter:
    image: prom/node-exporter:latest
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
    deploy:
      mode: global

volumes:
  prometheus-data:
  grafana-data:

configs:
  prometheus_config:
    file: ./prometheus.yml
```

## Production Best Practices

### 1. Manager Node Configuration

```bash
# Use odd number of managers (3, 5, or 7)
# 3 managers = tolerates 1 failure
# 5 managers = tolerates 2 failures

# Don't run application workloads on managers
docker node update --availability drain manager-1
```

### 2. Network Security

```bash
# Always use encrypted overlay networks for sensitive data
docker network create --driver overlay --opt encrypted secure-net

# Use TLS for Docker daemon communication
# Configure in /etc/docker/daemon.json
```

### 3. Resource Limits

```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
    reservations:
      cpus: '0.25'
      memory: 256M
```

### 4. Update Strategy

```yaml
deploy:
  update_config:
    parallelism: 2
    delay: 10s
    failure_action: rollback
    order: start-first
  rollback_config:
    parallelism: 2
    delay: 10s
```

### 5. Health Checks

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

### 6. Secrets Management

```bash
# Never use environment variables for secrets
# Use Docker secrets instead
docker secret create db_pass ./secret.txt

# Reference in service
--secret db_pass
```

### 7. Logging

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "5"
```

### 8. Backup Strategy

```bash
# Backup swarm configuration
docker swarm unlock-key --rotate
tar -czf swarm-backup.tar.gz /var/lib/docker/swarm/

# Backup volumes
docker run --rm -v mydata:/source -v $(pwd):/backup alpine \
    tar czf /backup/mydata.tar.gz -C /source .
```

## Exercises

### 🎯 Exercise 1: Initialize and Explore Swarm

Set up a single-node swarm and explore basic commands:

<details>
<summary>💡 Solution</summary>

```bash
# Initialize swarm
docker swarm init

# View swarm info
docker info | grep -A 15 Swarm

# List nodes
docker node ls

# Inspect current node
docker node inspect self --pretty

# View join tokens
docker swarm join-token worker
docker swarm join-token manager
```

</details>

### 🎯 Exercise 2: Deploy Your First Service

Create and manage a simple web service:

1. Create an nginx service with 3 replicas
2. Verify all replicas are running
3. Access the service
4. Scale to 5 replicas
5. View service logs
6. Remove the service

<details>
<summary>💡 Solution</summary>

```bash
# Create service
docker service create --name web --replicas 3 -p 80:80 nginx:alpine

# Verify replicas
docker service ls
docker service ps web

# Access service
curl http://localhost

# Scale to 5 replicas
docker service scale web=5
docker service ps web

# View logs
docker service logs web
docker service logs -f web

# Remove service
docker service rm web
```

</details>

### 🎯 Exercise 3: Rolling Update

Practice updating a service with zero downtime:

<details>
<summary>💡 Solution</summary>

```bash
# Create initial service
docker service create --name web \
    --replicas 4 \
    -p 80:80 \
    --update-delay 10s \
    --update-parallelism 2 \
    nginx:1.24-alpine

# Verify running
docker service ps web

# Update to new version
docker service update --image nginx:1.25-alpine web

# Watch the update (in another terminal)
watch docker service ps web

# Verify update complete
docker service inspect --pretty web

# Rollback if needed
docker service rollback web
```

</details>

### 🎯 Exercise 4: Secrets Management

Create and use secrets in a service:

<details>
<summary>💡 Solution</summary>

```bash
# Create secrets
echo "super_secret_password" | docker secret create db_password -
echo "my_api_key_12345" | docker secret create api_key -

# List secrets
docker secret ls

# Create service using secrets
docker service create --name secure-app \
    --secret db_password \
    --secret api_key \
    alpine \
    sh -c "cat /run/secrets/db_password && cat /run/secrets/api_key && sleep 3600"

# Verify secrets are mounted
docker service ps secure-app
CONTAINER_ID=$(docker ps -q --filter "name=secure-app")
docker exec $CONTAINER_ID cat /run/secrets/db_password
docker exec $CONTAINER_ID cat /run/secrets/api_key

# Clean up
docker service rm secure-app
docker secret rm db_password api_key
```

</details>

### 🎯 Exercise 5: Deploy a Stack

Deploy a complete application stack:

<details>
<summary>💡 Solution</summary>

```bash
# Create stack file
cat > myapp-stack.yml << 'EOF'
version: "3.8"

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
    networks:
      - webnet

  visualizer:
    image: dockersamples/visualizer
    ports:
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    deploy:
      placement:
        constraints:
          - node.role == manager
    networks:
      - webnet

networks:
  webnet:
EOF

# Deploy stack
docker stack deploy -c myapp-stack.yml myapp

# List stacks
docker stack ls

# List stack services
docker stack services myapp

# List stack tasks
docker stack ps myapp

# Access visualizer
echo "Open http://localhost:8080 to see swarm visualizer"

# Update replicas in stack file, then redeploy
sed -i 's/replicas: 3/replicas: 5/' myapp-stack.yml
docker stack deploy -c myapp-stack.yml myapp

# Clean up
docker stack rm myapp
rm myapp-stack.yml
```

</details>

### 🎯 Exercise 6: Node Labels and Constraints

Practice placement constraints with labels:

<details>
<summary>💡 Solution</summary>

```bash
# Add labels to current node
docker node update --label-add env=development $(docker node ls -q)
docker node update --label-add disk=ssd $(docker node ls -q)

# View labels
docker node inspect --pretty $(docker node ls -q) | grep -A 5 Labels

# Create service with constraint
docker service create --name dev-app \
    --constraint 'node.labels.env==development' \
    --replicas 2 \
    alpine sleep 3600

# Verify placement
docker service ps dev-app

# Create service that CAN'T be placed (no matching node)
docker service create --name prod-app \
    --constraint 'node.labels.env==production' \
    --replicas 2 \
    alpine sleep 3600

# Check - should show "no suitable node" error
docker service ps prod-app

# Clean up
docker service rm dev-app prod-app
docker node update --label-rm env $(docker node ls -q)
docker node update --label-rm disk $(docker node ls -q)
```

</details>

### 🎯 Exercise 7: Overlay Networking

Create services communicating over overlay network:

<details>
<summary>💡 Solution</summary>

```bash
# Create overlay network
docker network create --driver overlay --attachable app-network

# Create database service
docker service create --name redis \
    --network app-network \
    redis:alpine

# Create app service that connects to Redis
docker service create --name app \
    --network app-network \
    --replicas 2 \
    alpine \
    sh -c "apk add --no-cache redis && while true; do redis-cli -h redis ping; sleep 5; done"

# Check logs - should show PONG responses
sleep 10
docker service logs app

# Test DNS resolution
docker run --rm --network app-network alpine ping -c 3 redis

# Clean up
docker service rm app redis
docker network rm app-network
```

</details>

### 🎯 Exercise 8: Full Production-Like Deployment

Deploy a complete application with all best practices:

See [examples/production-stack/](examples/production-stack/) for the complete solution.

## 📁 Examples Directory

```text
examples/
├── basic-service/
│   └── README.md
├── web-stack/
│   ├── docker-stack.yml
│   └── README.md
├── secrets-demo/
│   ├── docker-stack.yml
│   └── README.md
├── rolling-updates/
│   ├── docker-stack.yml
│   └── README.md
├── production-stack/
│   ├── docker-stack.yml
│   ├── nginx.conf
│   ├── prometheus.yml
│   └── README.md
└── multi-node-simulation/
    ├── docker-compose.yml
    └── README.md
```

## 📝 Quick Reference

### Swarm Commands

| Command                   | Description        |
| ------------------------- | ------------------ |
| `docker swarm init`       | Initialize a swarm |
| `docker swarm join`       | Join a swarm       |
| `docker swarm leave`      | Leave a swarm      |
| `docker swarm join-token` | Get join tokens    |

### Node Commands

| Command                      | Description     |
| ---------------------------- | --------------- |
| `docker node ls`             | List nodes      |
| `docker node inspect`        | Node details    |
| `docker node ps`             | List node tasks |
| `docker node update`         | Update node     |
| `docker node promote/demote` | Change role     |

### Service Commands

| Command                   | Description      |
| ------------------------- | ---------------- |
| `docker service create`   | Create service   |
| `docker service ls`       | List services    |
| `docker service ps`       | List tasks       |
| `docker service logs`     | View logs        |
| `docker service update`   | Update service   |
| `docker service scale`    | Scale service    |
| `docker service rollback` | Rollback service |
| `docker service rm`       | Remove service   |

### Stack Commands

| Command                 | Description         |
| ----------------------- | ------------------- |
| `docker stack deploy`   | Deploy stack        |
| `docker stack ls`       | List stacks         |
| `docker stack services` | List stack services |
| `docker stack ps`       | List stack tasks    |
| `docker stack rm`       | Remove stack        |

### Secret & Config Commands

| Command                | Description   |
| ---------------------- | ------------- |
| `docker secret create` | Create secret |
| `docker secret ls`     | List secrets  |
| `docker config create` | Create config |
| `docker config ls`     | List configs  |

## ✅ Checklist

Before moving to production, make sure you can:

- [ ] Initialize and manage a swarm cluster
- [ ] Add and manage worker/manager nodes
- [ ] Create and scale services
- [ ] Deploy application stacks
- [ ] Configure overlay networks
- [ ] Use secrets for sensitive data
- [ ] Perform rolling updates and rollbacks
- [ ] Set up placement constraints
- [ ] Monitor swarm health
- [ ] Implement production best practices

⬅️ **Previous:** [Docker Compose](../07-docker-compose/README.md)
