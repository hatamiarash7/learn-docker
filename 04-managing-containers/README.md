# 📦 Managing Containers

Learn how to manage the full lifecycle of Docker containers - from running to stopping, monitoring, and resource management.

- [📦 Managing Containers](#-managing-containers)
  - [Running Containers](#running-containers)
    - [Basic Run Commands](#basic-run-commands)
    - [Container Run Options Reference](#container-run-options-reference)
    - [Restart Policies](#restart-policies)
    - [Executing Commands in Running Containers](#executing-commands-in-running-containers)
    - [Listing Containers](#listing-containers)
  - [Stopping and Removing Containers](#stopping-and-removing-containers)
    - [Stopping Containers](#stopping-containers)
    - [Pausing and Unpausing](#pausing-and-unpausing)
    - [Removing Containers](#removing-containers)
    - [Container Lifecycle Diagram](#container-lifecycle-diagram)
  - [Managing Container Resources](#managing-container-resources)
    - [Inspecting Containers](#inspecting-containers)
    - [Container Statistics](#container-statistics)
    - [Copying Files](#copying-files)
    - [Container Differences](#container-differences)
  - [Accessing Container Logs](#accessing-container-logs)
    - [Basic Logging](#basic-logging)
    - [Log Drivers](#log-drivers)
    - [Log Driver Options](#log-driver-options)
  - [Limiting Resources](#limiting-resources)
    - [Memory Limits](#memory-limits)
    - [CPU Limits](#cpu-limits)
    - [Combined Resource Limits](#combined-resource-limits)
    - [Viewing Resource Limits](#viewing-resource-limits)
    - [PIDs Limit](#pids-limit)
  - [Exercises](#exercises)
    - [🎯 Exercise 1: Container Lifecycle](#-exercise-1-container-lifecycle)
    - [🎯 Exercise 2: Log Management](#-exercise-2-log-management)
    - [🎯 Exercise 3: Resource Limits](#-exercise-3-resource-limits)
    - [🎯 Exercise 4: Container Inspection](#-exercise-4-container-inspection)
    - [🎯 Exercise 5: Multi-Container Management](#-exercise-5-multi-container-management)
  - [📝 Quick Reference](#-quick-reference)
  - [✅ Checklist](#-checklist)

## Running Containers

### Basic Run Commands

```bash
# Run a container (pulls image if not present)
docker run nginx:alpine

# Run in detached mode (background)
docker run -d nginx:alpine

# Run with a custom name
docker run -d --name my-nginx nginx:alpine

# Run interactively with TTY
docker run -it alpine /bin/sh

# Run and automatically remove when stopped
docker run --rm alpine echo "I will be removed"

# Run with environment variables
docker run -d -e MYSQL_ROOT_PASSWORD=secret mariadb:latest

# Run with port mapping
docker run -d -p 8080:80 nginx:alpine

# Run with volume mount
docker run -d -v /host/path:/container/path nginx:alpine

# Run with working directory
docker run -w /app alpine pwd
```

### Container Run Options Reference

| Option       | Description                | Example                       |
| ------------ | -------------------------- | ----------------------------- |
| `-d`         | Detached mode (background) | `docker run -d nginx`         |
| `-it`        | Interactive with TTY       | `docker run -it alpine sh`    |
| `--name`     | Assign name                | `docker run --name web nginx` |
| `-p`         | Port mapping               | `docker run -p 8080:80 nginx` |
| `-P`         | Publish all exposed ports  | `docker run -P nginx`         |
| `-e`         | Environment variable       | `docker run -e VAR=value`     |
| `-v`         | Volume mount               | `docker run -v /data:/data`   |
| `--rm`       | Auto-remove on exit        | `docker run --rm alpine`      |
| `-w`         | Working directory          | `docker run -w /app node`     |
| `--restart`  | Restart policy             | `docker run --restart=always` |
| `--network`  | Connect to network         | `docker run --network=mynet`  |
| `-u`         | User to run as             | `docker run -u 1000:1000`     |
| `--hostname` | Container hostname         | `docker run --hostname=web1`  |

### Restart Policies

```bash
# Never restart (default)
docker run -d --restart=no nginx:alpine

# Always restart
docker run -d --restart=always nginx:alpine

# Restart on failure (up to 3 times)
docker run -d --restart=on-failure:3 nginx:alpine

# Restart unless manually stopped
docker run -d --restart=unless-stopped nginx:alpine
```

### Executing Commands in Running Containers

```bash
# Execute a command in a running container
docker exec my-container ls -la

# Interactive shell in running container
docker exec -it my-container /bin/sh

# Execute as specific user
docker exec -u root my-container whoami

# Execute with environment variable
docker exec -e MY_VAR=value my-container env

# Execute with working directory
docker exec -w /app my-container pwd
```

### Listing Containers

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# List only container IDs
docker ps -q

# List with custom format
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"

# List last created container
docker ps -l

# Filter containers
docker ps --filter "status=running"
docker ps --filter "name=nginx"
docker ps --filter "ancestor=alpine"
```

## Stopping and Removing Containers

### Stopping Containers

```bash
# Stop a container gracefully (SIGTERM, then SIGKILL after 10s)
docker stop my-container

# Stop with custom timeout (30 seconds)
docker stop -t 30 my-container

# Stop multiple containers
docker stop container1 container2 container3

# Stop all running containers
docker stop $(docker ps -q)

# Kill a container immediately (SIGKILL)
docker kill my-container

# Send specific signal
docker kill --signal=SIGHUP my-container
```

### Pausing and Unpausing

```bash
# Pause a container (freezes processes)
docker pause my-container

# Unpause a container
docker unpause my-container
```

### Removing Containers

```bash
# Remove a stopped container
docker rm my-container

# Force remove a running container
docker rm -f my-container

# Remove multiple containers
docker rm container1 container2 container3

# Remove all stopped containers
docker container prune

# Remove all containers (running and stopped)
docker rm -f $(docker ps -aq)
```

### Container Lifecycle Diagram

```text
┌─────────────────────────────────────────────────────────────┐
│                    Container Lifecycle                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Created ──► Running ──► Paused ──► Running                │
│      │           │           │          │                   │
│      │           │           └──────────┘                   │
│      │           │                                          │
│      │           ▼                                          │
│      │        Stopped ──────────► Removed                   │
│      │           │                                          │
│      │           ▼                                          │
│      └───────► Restarted ──► Running                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Commands:
- docker create → Created
- docker start  → Running
- docker pause  → Paused
- docker stop   → Stopped
- docker rm     → Removed
```

## Managing Container Resources

### Inspecting Containers

```bash
# Full container details (JSON)
docker inspect my-container

# Get specific information
docker inspect --format='{{.State.Status}}' my-container
docker inspect --format='{{.NetworkSettings.IPAddress}}' my-container
docker inspect --format='{{.Config.Env}}' my-container
docker inspect --format='{{json .Mounts}}' my-container | jq

# Get container ID
docker inspect --format='{{.Id}}' my-container

# Get container logs path
docker inspect --format='{{.LogPath}}' my-container
```

### Container Statistics

```bash
# Real-time resource usage
docker stats

# Stats for specific container
docker stats my-container

# One-time stats (no streaming)
docker stats --no-stream

# Custom format
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### Copying Files

```bash
# Copy file from host to container
docker cp local-file.txt my-container:/app/file.txt

# Copy file from container to host
docker cp my-container:/app/file.txt ./local-file.txt

# Copy directory
docker cp ./my-folder my-container:/app/

# Copy from container directory
docker cp my-container:/app/logs ./logs
```

### Container Differences

```bash
# Show changes to container's filesystem
docker diff my-container

# Output:
# A /new-file      (Added)
# C /modified-dir  (Changed)
# D /deleted-file  (Deleted)
```

## Accessing Container Logs

### Basic Logging

```bash
# View container logs
docker logs my-container

# Follow logs (like tail -f)
docker logs -f my-container

# Show timestamps
docker logs -t my-container

# Show last N lines
docker logs --tail 100 my-container

# Show logs since timestamp
docker logs --since 2024-01-01T00:00:00 my-container

# Show logs from last 10 minutes
docker logs --since 10m my-container

# Show logs until timestamp
docker logs --until 2024-01-01T12:00:00 my-container

# Combine options
docker logs -f --tail 50 -t my-container
```

### Log Drivers

Docker supports various logging drivers:

```bash
# Run with JSON file driver (default)
docker run -d --log-driver json-file nginx:alpine

# Run with syslog driver
docker run -d --log-driver syslog nginx:alpine

# Run with no logging
docker run -d --log-driver none nginx:alpine

# JSON file with options
docker run -d \
    --log-driver json-file \
    --log-opt max-size=10m \
    --log-opt max-file=3 \
    nginx:alpine
```

### Log Driver Options

| Driver      | Description                 |
| ----------- | --------------------------- |
| `json-file` | Default, logs to JSON files |
| `syslog`    | Sends to syslog             |
| `journald`  | Sends to systemd journal    |
| `gelf`      | Graylog Extended Log Format |
| `fluentd`   | Sends to Fluentd            |
| `awslogs`   | Amazon CloudWatch Logs      |
| `none`      | No logging                  |

## Limiting Resources

### Memory Limits

```bash
# Limit memory to 512MB
docker run -d --memory=512m nginx:alpine

# Limit memory with swap
docker run -d --memory=512m --memory-swap=1g nginx:alpine

# Memory reservation (soft limit)
docker run -d --memory=512m --memory-reservation=256m nginx:alpine

# Disable OOM killer
docker run -d --memory=512m --oom-kill-disable nginx:alpine
```

### CPU Limits

```bash
# Limit to 50% of one CPU
docker run -d --cpus=0.5 nginx:alpine

# Limit to 2 CPUs
docker run -d --cpus=2 nginx:alpine

# Pin to specific CPUs (0 and 1)
docker run -d --cpuset-cpus="0,1" nginx:alpine

# CPU shares (relative weight, default 1024)
docker run -d --cpu-shares=512 nginx:alpine
```

### Combined Resource Limits

```bash
# Production-ready container with limits
docker run -d \
    --name production-app \
    --memory=1g \
    --memory-reservation=512m \
    --cpus=2 \
    --restart=unless-stopped \
    --log-opt max-size=10m \
    --log-opt max-file=3 \
    nginx:alpine
```

### Viewing Resource Limits

```bash
# Check resource limits
docker inspect --format='{{.HostConfig.Memory}}' my-container
docker inspect --format='{{.HostConfig.NanoCpus}}' my-container

# Monitor resource usage
docker stats my-container
```

### PIDs Limit

```bash
# Limit number of processes
docker run -d --pids-limit=100 nginx:alpine
```

## Exercises

### 🎯 Exercise 1: Container Lifecycle

Practice the full container lifecycle:

1. Create a container without starting it
2. Start the container
3. Pause and unpause the container
4. Stop the container
5. Restart the container
6. Remove the container

<details>
<summary>💡 Solution</summary>

```bash
# Create without starting
docker create --name lifecycle-test nginx:alpine

# Verify it's created but not running
docker ps -a | grep lifecycle-test

# Start the container
docker start lifecycle-test

# Verify it's running
docker ps | grep lifecycle-test

# Pause the container
docker pause lifecycle-test

# Verify it's paused
docker ps | grep lifecycle-test

# Unpause
docker unpause lifecycle-test

# Stop gracefully
docker stop lifecycle-test

# Restart
docker restart lifecycle-test

# Verify running again
docker ps | grep lifecycle-test

# Remove (force since it's running)
docker rm -f lifecycle-test
```

</details>

### 🎯 Exercise 2: Log Management

Work with container logs:

1. Run Nginx with logging configured
2. Generate some access logs
3. View and filter the logs
4. Find specific log entries

<details>
<summary>💡 Solution</summary>

```bash
# Run Nginx with log options
docker run -d \
    --name log-test \
    -p 8080:80 \
    --log-opt max-size=1m \
    --log-opt max-file=3 \
    nginx:alpine

# Generate some logs
for i in {1..10}; do
    curl -s http://localhost:8080 > /dev/null
done

# Also generate a 404
curl -s http://localhost:8080/not-found > /dev/null

# View logs
docker logs log-test

# View with timestamps
docker logs -t log-test

# Follow logs (Ctrl+C to exit)
docker logs -f log-test &
curl http://localhost:8080
kill %1

# View last 5 lines
docker logs --tail 5 log-test

# View logs from last 1 minute
docker logs --since 1m log-test

# Cleanup
docker rm -f log-test
```

</details>

### 🎯 Exercise 3: Resource Limits

Practice setting resource limits:

1. Run a container with memory and CPU limits
2. Monitor resource usage
3. Test what happens when limits are exceeded

<details>
<summary>💡 Solution</summary>

```bash
# Run with strict limits
docker run -d \
    --name resource-test \
    --memory=64m \
    --cpus=0.5 \
    alpine \
    sleep 3600

# Check limits were applied
docker inspect --format='Memory: {{.HostConfig.Memory}}' resource-test
docker inspect --format='CPUs: {{.HostConfig.NanoCpus}}' resource-test

# Monitor resources
docker stats resource-test --no-stream

# Test memory stress (this container will be killed)
docker run --rm --memory=32m alpine sh -c "dd if=/dev/zero of=/dev/null bs=1M" &

# Watch for OOM kill in another terminal
docker events --filter 'event=oom' &

# Cleanup
docker rm -f resource-test
```

</details>

### 🎯 Exercise 4: Container Inspection

Practice inspecting and debugging containers:

1. Run a container with various settings
2. Extract specific information using inspect
3. Copy files in and out of the container

<details>
<summary>💡 Solution</summary>

```bash
# Run container with various settings
docker run -d \
    --name inspect-test \
    -e MY_VAR="Hello" \
    -e ANOTHER_VAR="World" \
    -p 8080:80 \
    --restart=unless-stopped \
    nginx:alpine

# Get IP address
docker inspect --format='{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' inspect-test

# Get environment variables
docker inspect --format='{{.Config.Env}}' inspect-test

# Get port mappings
docker inspect --format='{{json .NetworkSettings.Ports}}' inspect-test | jq

# Get restart policy
docker inspect --format='{{.HostConfig.RestartPolicy.Name}}' inspect-test

# Check container status
docker inspect --format='{{.State.Status}}' inspect-test

# Create a file inside the container
docker exec inspect-test sh -c 'echo "Hello from container" > /tmp/hello.txt'

# Copy file from container
docker cp inspect-test:/tmp/hello.txt ./hello.txt
cat hello.txt

# Copy file to container
echo "Hello from host" > greeting.txt
docker cp greeting.txt inspect-test:/tmp/greeting.txt
docker exec inspect-test cat /tmp/greeting.txt

# Cleanup
docker rm -f inspect-test
rm hello.txt greeting.txt
```

</details>

### 🎯 Exercise 5: Multi-Container Management

Manage multiple containers together:

1. Start several containers
2. List and filter them
3. Stop and remove them in bulk

<details>
<summary>💡 Solution</summary>

```bash
# Start multiple containers with labels
docker run -d --name web1 -l env=prod -l app=web nginx:alpine
docker run -d --name web2 -l env=prod -l app=web nginx:alpine
docker run -d --name cache1 -l env=prod -l app=cache redis:alpine
docker run -d --name worker1 -l env=dev -l app=worker alpine sleep 3600

# List all with custom format
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"

# Filter by label
docker ps --filter "label=env=prod"
docker ps --filter "label=app=web"

# Get stats for all
docker stats --no-stream

# Stop all prod containers
docker stop $(docker ps -q --filter "label=env=prod")

# Remove all stopped containers
docker container prune -f

# Remove the remaining container
docker rm -f worker1
```

</details>

## 📝 Quick Reference

| Command          | Description                  |
| ---------------- | ---------------------------- |
| `docker run`     | Create and start a container |
| `docker start`   | Start a stopped container    |
| `docker stop`    | Stop a running container     |
| `docker restart` | Restart a container          |
| `docker pause`   | Pause a container            |
| `docker unpause` | Unpause a container          |
| `docker rm`      | Remove a container           |
| `docker exec`    | Execute command in container |
| `docker logs`    | View container logs          |
| `docker inspect` | View container details       |
| `docker stats`   | View resource usage          |
| `docker cp`      | Copy files to/from container |
| `docker diff`    | Show filesystem changes      |

## ✅ Checklist

Before moving to the next section, make sure you can:

- [ ] Run containers in various modes (detached, interactive)
- [ ] Stop, start, restart, and remove containers
- [ ] Execute commands inside running containers
- [ ] View and manage container logs
- [ ] Set memory and CPU limits
- [ ] Inspect container details
- [ ] Copy files to and from containers
- [ ] Use restart policies effectively

---

⬅️ **Previous:** [Build Your Own Images](../03-build-your-own-images/README.md)

➡️ **Next:** [Networking with Docker](../05-networking-with-docker/README.md)
