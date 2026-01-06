# Part 2 - Controlled Container Deployment

## Description
This script deploys all required containers with controlled timing.

## Requirements
- log-producer:1.0 image built
- cpu-worker:latest image built
- toolbox:latest image built

## Deployment Plan

| Order | Container | Image | Wait Time |
|-------|-----------|-------|-----------|
| 1 | producer-1 | log-producer:1.0 | 15s |
| 2 | producer-2 | log-producer:1.0 | 15s |
| 3 | producer-3 | log-producer:1.0 | 15s |
| 4 | worker-1 | cpu-worker:latest | 15s |
| 5 | worker-2 | cpu-worker:latest | 15s |
| 6 | toolbox-1 | toolbox:latest | - |

## Usage
```bash
# Make executable
chmod +x deploy-containers.sh

# Run deployment
./deploy-containers.sh
```
### Output:
```bash

========================================
  Container Deployment Script
========================================

[1/6] Starting producer-1...
74b08f5b7ba5015cac98a53725f108e680cf512de53e085d9876f9a69b4a8f6b
Waiting 15 seconds...
  Ready!                    
[2/6] Starting producer-2...
2cf86f203c466d00bad9f1e7fd3cd0101050cc4b7e6f6e2a03fa40fe97a92f84
Waiting 15 seconds...
  Ready!                    
[3/6] Starting producer-3...
f2e9a101cbbaf091302047e6d73b7e570dd793e7c3374a10396c25dec5b174b6
Waiting 15 seconds...
  Ready!                    
[4/6] Starting worker-1...
d0b12e105ff243251dfc413b96b08244fe0bead6ff35cadc04d7b8e458353bca
Waiting 15 seconds...
  Ready!                    
[5/6] Starting worker-2...
74f528a7ae31242d2664799248331e6f41e6af7335d835f6ff74492f78bccf42
Waiting 15 seconds...
  Ready!                    
[6/6] Starting toolbox-1...
56605568f268ed8d6deb47d916d0439a966197fceffda666be45c77c39fe4b8c

========================================
  All containers deployed!
========================================

Running containers:
NAMES        IMAGE               STATUS
toolbox-1    toolbox:latest      Up Less than a second
worker-2     cpu-worker:latest   Up 15 seconds
worker-1     cpu-worker:latest   Up 30 seconds
producer-3   log-producer:1.0    Up 45 seconds
producer-2   log-producer:1.0    Up About a minute
producer-1   log-producer:1.0    Up About a minute

```




## Verification
```bash
# Check all containers are running
docker ps

### output 
CONTAINER ID   IMAGE               COMMAND                  CREATED              STATUS              PORTS     NAMES
56605568f268   toolbox:latest      "tail -f /dev/null"      24 seconds ago       Up 24 seconds                 toolbox-1
74f528a7ae31   cpu-worker:latest   "python3 /app/worker…"   39 seconds ago       Up 39 seconds                 worker-2
d0b12e105ff2   cpu-worker:latest   "python3 /app/worker…"   55 seconds ago       Up 54 seconds                 worker-1
f2e9a101cbba   log-producer:1.0    "python3 /app/logger…"   About a minute ago   Up About a minute             producer-3
2cf86f203c46   log-producer:1.0    "python3 /app/logger…"   About a minute ago   Up About a minute             producer-2
74b08f5b7ba5   log-producer:1.0    "python3 /app/logger…"   About a minute ago   Up About a minute             producer-1

# Check specific container logs
docker logs producer-1
docker logs worker-1
docker logs toolbox-1

# Check container stats
docker stats
```
### output:
```bash

docker logs worker-1
[CPU-WORKER] Started
[CPU-WORKER] Working... Done (18811260 operations)
[CPU-WORKER] Resting...
[CPU-WORKER] Working... Done (19032097 operations)
[CPU-WORKER] Resting...
[CPU-WORKER] Working... Done (19104452 operations)
[CPU-WORKER] Resting...
[CPU-WORKER] Working... Done (17782461 operations)
[CPU-WORKER] Resting...
[CPU-WORKER] Working... Done (18739425 operations)
[CPU-WORKER] Resting...
[CPU-WORKER] Working... Done (18803729 operations)
CONTAINER ID   NAME         CPU %     MEM USAGE / LIMIT     MEM %     NET I/O         BLOCK I/O   PIDS 
56605568f268   toolbox-1    0.00%     452KiB / 15.24GiB     0.00%     3.88kB / 126B   0B / 0B     1 
74f528a7ae31   worker-2     48.29%    3.383MiB / 15.24GiB   0.02%     4.01kB / 126B   0B / 0B     1 
d0b12e105ff2   worker-1     72.38%    3.383MiB / 15.24GiB   0.02%     4.13kB / 126B   0B / 0B     1 
f2e9a101cbba   producer-3   0.00%     5.52MiB / 15.24GiB    0.04%     4.53kB / 126B   0B / 0B     1 
2cf86f203c46   producer-2   0.00%     5.523MiB / 15.24GiB   0.04%     4.66kB / 126B   0B / 0B     1 
74b08f5b7ba5   producer-1   0.00%     5.52MiB / 15.24GiB    0.04%     5.04kB / 126B   0B / 0B     1 

```

## Cleanup
```bash
# Stop all containers
docker stop producer-1 producer-2 producer-3 worker-1 worker-2 toolbox-1

# Remove all containers
docker rm producer-1 producer-2 producer-3 worker-1 worker-2 toolbox-1
```
