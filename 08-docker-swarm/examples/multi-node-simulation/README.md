# Multi-Node Swarm Simulation

Simulates a multi-node Docker Swarm cluster on a single machine using Docker-in-Docker (DinD).

## ⚠️ Important Note

This is for **learning and testing only**. For production, use:

- Physical machines
- Virtual machines
- Cloud instances

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      HOST MACHINE                                │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    DOCKER COMPOSE                           │ │
│  │                                                             │ │
│  │   ┌─────────────┐  ┌─────────────┐                         │ │
│  │   │  Manager 1  │  │  Manager 2  │   ← Managers            │ │
│  │   │   (DinD)    │  │   (DinD)    │                         │ │
│  │   └─────────────┘  └─────────────┘                         │ │
│  │                                                             │ │
│  │   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │ │
│  │   │  Worker 1   │  │  Worker 2   │  │  Worker 3   │       │ │
│  │   │   (DinD)    │  │   (DinD)    │  │   (DinD)    │       │ │
│  │   └─────────────┘  └─────────────┘  └─────────────┘       │ │
│  │                         ↑                                   │ │
│  │                    Workers                                  │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Quick Start

### 1. Start the Nodes

```bash
docker compose up -d
```

### 2. Initialize Swarm on Manager1

```bash
# Initialize swarm
docker exec swarm-manager1 docker swarm init --advertise-addr manager1

# Get join tokens
MANAGER_TOKEN=$(docker exec swarm-manager1 docker swarm join-token manager -q)
WORKER_TOKEN=$(docker exec swarm-manager1 docker swarm join-token worker -q)
```

### 3. Join Other Nodes

```bash
# Join manager2
docker exec swarm-manager2 docker swarm join --token $MANAGER_TOKEN manager1:2377

# Join workers
docker exec swarm-worker1 docker swarm join --token $WORKER_TOKEN manager1:2377
docker exec swarm-worker2 docker swarm join --token $WORKER_TOKEN manager1:2377
docker exec swarm-worker3 docker swarm join --token $WORKER_TOKEN manager1:2377
```

### 4. Verify Cluster

```bash
docker exec swarm-manager1 docker node ls
```

Expected output:

```
ID          HOSTNAME   STATUS  AVAILABILITY  MANAGER STATUS
abc123 *    manager1   Ready   Active        Leader
def456      manager2   Ready   Active        Reachable
ghi789      worker1    Ready   Active        
jkl012      worker2    Ready   Active        
mno345      worker3    Ready   Active        
```

## Deploy a Service

```bash
# Create a service
docker exec swarm-manager1 docker service create \
    --name web \
    --replicas 6 \
    -p 80:80 \
    nginx:alpine

# Check service distribution
docker exec swarm-manager1 docker service ps web
```

## Add Visualizer

```bash
docker exec swarm-manager1 docker service create \
    --name visualizer \
    --publish 9000:8080 \
    --constraint 'node.role==manager' \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    dockersamples/visualizer

# Access at http://localhost:9000
```

## Test Failover

```bash
# Stop a worker
docker stop swarm-worker1

# Watch tasks reschedule
docker exec swarm-manager1 docker service ps web

# Start worker again
docker start swarm-worker1

# Watch it rejoin
docker exec swarm-manager1 docker node ls
```

## Interact with Nodes

```bash
# Connect to manager1
docker exec -it swarm-manager1 sh

# Run docker commands inside
docker node ls
docker service ls
docker service ps web
exit
```

## Automated Setup Script

```bash
#!/bin/bash
# setup-swarm.sh

echo "Starting nodes..."
docker compose up -d
sleep 10

echo "Initializing swarm..."
docker exec swarm-manager1 docker swarm init --advertise-addr manager1

echo "Getting tokens..."
MANAGER_TOKEN=$(docker exec swarm-manager1 docker swarm join-token manager -q)
WORKER_TOKEN=$(docker exec swarm-manager1 docker swarm join-token worker -q)

echo "Joining manager2..."
docker exec swarm-manager2 docker swarm join --token $MANAGER_TOKEN manager1:2377

echo "Joining workers..."
for i in 1 2 3; do
    docker exec swarm-worker$i docker swarm join --token $WORKER_TOKEN manager1:2377
done

echo "Cluster status:"
docker exec swarm-manager1 docker node ls

echo ""
echo "Swarm cluster is ready!"
echo "Access manager1: docker exec -it swarm-manager1 sh"
```

## Clean Up

```bash
# Remove all services from swarm
docker exec swarm-manager1 docker service rm $(docker exec swarm-manager1 docker service ls -q) 2>/dev/null

# Stop and remove all containers
docker compose down -v
```

## Limitations

- Networking between DinD containers and host is complex
- Performance overhead from nested Docker
- Not suitable for production testing
- Some features may behave differently

## For Real Multi-Node Testing

Consider using:

- **Docker Machine** with VirtualBox
- **Vagrant** with Docker provisioner
- **Cloud providers** (AWS, GCP, Azure)
- **Play with Docker** (<https://labs.play-with-docker.com>)
