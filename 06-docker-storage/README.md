# 💾 Docker Storage and Volumes

Master Docker storage concepts to persist data and share files between containers and the host.

- [💾 Docker Storage and Volumes](#-docker-storage-and-volumes)
  - [Understanding Docker Storage](#understanding-docker-storage)
    - [The Problem: Container Ephemeral Storage](#the-problem-container-ephemeral-storage)
    - [The Solution: External Storage](#the-solution-external-storage)
  - [Types of Storage](#types-of-storage)
    - [Comparison](#comparison)
    - [When to Use What](#when-to-use-what)
  - [Volumes](#volumes)
    - [Why Volumes?](#why-volumes)
    - [Creating and Managing Volumes](#creating-and-managing-volumes)
    - [Using Volumes with Containers](#using-volumes-with-containers)
    - [`--mount` vs `-v` Syntax](#--mount-vs--v-syntax)
    - [Anonymous Volumes](#anonymous-volumes)
    - [Volume in Dockerfile](#volume-in-dockerfile)
  - [Bind Mounts](#bind-mounts)
    - [Creating Bind Mounts](#creating-bind-mounts)
    - [Bind Mount Options](#bind-mount-options)
    - [Development Workflow with Bind Mounts](#development-workflow-with-bind-mounts)
    - [Bind Mount Gotchas](#bind-mount-gotchas)
  - [tmpfs Mounts](#tmpfs-mounts)
    - [Use Cases](#use-cases)
    - [Creating tmpfs Mounts](#creating-tmpfs-mounts)
    - [tmpfs Options](#tmpfs-options)
    - [Example: Secure Secret Handling](#example-secure-secret-handling)
  - [Volume Drivers](#volume-drivers)
    - [Available Drivers](#available-drivers)
    - [Using Local Driver with Options](#using-local-driver-with-options)
  - [Backup and Restore](#backup-and-restore)
    - [Backup a Volume](#backup-a-volume)
    - [Restore a Volume](#restore-a-volume)
    - [Copy Data Between Volumes](#copy-data-between-volumes)
    - [Automated Backup Script](#automated-backup-script)
    - [Safe approach](#safe-approach)
  - [Best Practices](#best-practices)
    - [1. Use Volumes for Persistent Data](#1-use-volumes-for-persistent-data)
    - [2. Use Bind Mounts for Development Only](#2-use-bind-mounts-for-development-only)
    - [3. Make Volumes Read-Only When Possible](#3-make-volumes-read-only-when-possible)
    - [4. Use tmpfs for Sensitive Data](#4-use-tmpfs-for-sensitive-data)
    - [5. Name Your Volumes Descriptively](#5-name-your-volumes-descriptively)
    - [6. Clean Up Unused Volumes](#6-clean-up-unused-volumes)
  - [Exercises](#exercises)
    - [🎯 Exercise 1: Volume Basics](#-exercise-1-volume-basics)
    - [🎯 Exercise 2: Database Persistence](#-exercise-2-database-persistence)
    - [🎯 Exercise 3: Bind Mounts for Development](#-exercise-3-bind-mounts-for-development)
    - [🎯 Exercise 4: Volume Backup and Restore](#-exercise-4-volume-backup-and-restore)
    - [🎯 Exercise 5: Sharing Volumes Between Containers](#-exercise-5-sharing-volumes-between-containers)
    - [🎯 Exercise 6: tmpfs for Sensitive Data](#-exercise-6-tmpfs-for-sensitive-data)
  - [📁 Examples Directory](#-examples-directory)
  - [📝 Quick Reference](#-quick-reference)
  - [✅ Checklist](#-checklist)

## Understanding Docker Storage

### The Problem: Container Ephemeral Storage

By default, all files created inside a container are stored on a **writable container layer**. This means:

- Data is lost when the container is removed
- Data cannot be easily shared between containers
- Writing to the container layer requires a storage driver (less performant)

```text
┌─────────────────────────────────────────────────────────────┐
│                    Container Layer                          │
│              (Writable - Ephemeral Data)                    │
├─────────────────────────────────────────────────────────────┤
│                    Image Layer 3                            │
├─────────────────────────────────────────────────────────────┤
│                    Image Layer 2                            │
├─────────────────────────────────────────────────────────────┤
│                    Image Layer 1                            │
│                    (Read-Only)                              │
└─────────────────────────────────────────────────────────────┘
```

### The Solution: External Storage

Docker provides three ways to persist data:

```text
┌────────────────────────────────────────────────────────────────┐
│                         Container                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Application                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│           │                │                │                  │
│           ▼                ▼                ▼                  │
│      ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│      │  Volume  │    │  Bind    │    │  tmpfs   │              │
│      │          │    │  Mount   │    │  Mount   │              │
│      └────┬─────┘    └────┬─────┘    └────┬─────┘              │
└───────────┼───────────────┼───────────────┼────────────────────┘
            │               │               │
            ▼               ▼               ▼
     ┌────────────┐  ┌────────────┐  ┌────────────┐
     │  Docker    │  │   Host     │  │   Host     │
     │  Area      │  │ Filesystem │  │   Memory   │
     │ /var/lib/  │  │ (anywhere) │  │   (RAM)    │
     │ docker/    │  │            │  │            │
     │ volumes/   │  │            │  │            │
     └────────────┘  └────────────┘  └────────────┘
```

## Types of Storage

### Comparison

| Feature     | Volumes             | Bind Mounts          | tmpfs              |
| ----------- | ------------------- | -------------------- | ------------------ |
| Location    | Docker manages      | You specify          | Memory             |
| Persistence | Yes                 | Yes                  | No (RAM)           |
| Sharing     | Easy                | Manual               | No                 |
| Performance | Good                | Good                 | Best               |
| Backup      | Easy                | Manual               | N/A                |
| Use Case    | Databases, app data | Development, configs | Secrets, temp data |

### When to Use What

| Scenario                       | Best Choice     |
| ------------------------------ | --------------- |
| Database storage               | **Volumes**     |
| Application data               | **Volumes**     |
| Development (live code reload) | **Bind Mounts** |
| Configuration files            | **Bind Mounts** |
| Log files                      | **Bind Mounts** |
| Secrets/sensitive data         | **tmpfs**       |
| Temporary/cache data           | **tmpfs**       |
| Sharing between containers     | **Volumes**     |

## Volumes

Volumes are the **preferred mechanism** for persisting data in Docker.

### Why Volumes?

- Managed by Docker (easy to backup, migrate)
- Work on both Linux and Windows
- Can be shared among multiple containers
- Volume drivers allow remote storage (NFS, cloud)
- New volumes can be pre-populated by containers

### Creating and Managing Volumes

```bash
# Create a volume
docker volume create my-data

# List volumes
docker volume ls

# Inspect a volume
docker volume inspect my-data

# Remove a volume
docker volume rm my-data

# Remove all unused volumes
docker volume prune

# Remove all unused volumes without confirmation
docker volume prune -f
```

### Using Volumes with Containers

```bash
# Mount volume to container (recommended syntax)
docker run -d \
    --name db \
    --mount source=mysql-data,target=/var/lib/mysql \
    db:latest

# Short syntax with -v flag
docker run -d \
    --name db \
    -v mysql-data:/var/lib/mysql \
    db:latest

# Read-only volume
docker run -d \
    --mount source=config,target=/app/config,readonly \
    my-app

# Or with -v
docker run -d -v config:/app/config:ro my-app
```

### `--mount` vs `-v` Syntax

| Feature        | --mount               | -v                 |
| -------------- | --------------------- | ------------------ |
| Readability    | More verbose, clearer | Shorter            |
| Creates volume | Must exist            | Creates if missing |
| Error handling | Better errors         | Silent failures    |
| Recommended    | Yes (for new users)   |                    |

**--mount syntax:**

```bash
--mount type=volume,source=vol-name,target=/path,readonly
```

**-v syntax:**

```bash
-v volume-name:/path:ro
```

### Anonymous Volumes

```bash
# Create anonymous volume (Docker generates name)
docker run -d -v /var/lib/mysql mariadb:latest

# List and you'll see random name
docker volume ls
```

### Volume in Dockerfile

```dockerfile
FROM alpine:3.18

# Declare a volume mount point
# This creates an anonymous volume when container runs
VOLUME /data

# Data written to /data will persist
WORKDIR /data
CMD ["sh", "-c", "echo 'Hello' > /data/hello.txt && cat /data/hello.txt"]
```

## Bind Mounts

Bind mounts map a **host directory** directly into a container.

### Creating Bind Mounts

```bash
# Mount current directory into container
docker run -d \
    --name web \
    --mount type=bind,source=$(pwd)/html,target=/usr/share/nginx/html \
    nginx:alpine

# Short syntax with -v
docker run -d \
    --name web \
    -v $(pwd)/html:/usr/share/nginx/html \
    nginx:alpine

# Read-only bind mount
docker run -d \
    -v $(pwd)/config:/app/config:ro \
    my-app

# With specific options
docker run -d \
    --mount type=bind,source=$(pwd)/data,target=/data,readonly \
    alpine
```

### Bind Mount Options

| Option             | Description                                              |
| ------------------ | -------------------------------------------------------- |
| `ro` or `readonly` | Read-only mount                                          |
| `rw`               | Read-write (default)                                     |
| `Z`                | SELinux private label ( only this container can use it ) |
| `z`                | SELinux shared label ( many containers can share it )    |

### Development Workflow with Bind Mounts

```bash
# Node.js development - code changes reflect immediately
docker run -d \
    --name dev-app \
    -p 3000:3000 \
    -v $(pwd):/app \
    -w /app \
    node:20-alpine \
    npm run dev

# Python development with Flask
docker run -d \
    --name flask-dev \
    -p 5000:5000 \
    -v $(pwd):/app \
    -w /app \
    -e FLASK_DEBUG=1 \
    python:3.11-alpine \
    flask run --host=0.0.0.0
```

### Bind Mount Gotchas

```bash
# ⚠️ If host path doesn't exist, Docker creates it as a directory
docker run -v /nonexistent/path:/app alpine ls /app
# Creates /nonexistent/path as directory (might not be what you want)

# ⚠️ Container files are overwritten by host mount
# If you mount to a directory with existing container files,
# the container files are hidden (not deleted, but inaccessible)

# ✅ Use --mount for better error handling
docker run --mount type=bind,source=/nonexistent,target=/app alpine
# Error: source path does not exist
```

## tmpfs Mounts

tmpfs mounts store data in the **host's memory only**. Data is never written to disk.

### Use Cases

- Sensitive data (secrets, credentials)
- Temporary data that doesn't need to persist
- Performance-critical temporary storage

### Creating tmpfs Mounts

```bash
# Create tmpfs mount
docker run -d \
    --name secure-app \
    --mount type=tmpfs,target=/run/secrets \
    my-app

# With size limit
docker run -d \
    --mount type=tmpfs,target=/tmp,tmpfs-size=100m \
    alpine

# Short syntax
docker run -d --tmpfs /tmp:size=100m alpine

# With specific options
docker run -d \
    --mount type=tmpfs,target=/tmp,tmpfs-size=100m,tmpfs-mode=0755 \
    alpine
```

### tmpfs Options

| Option       | Description                              |
| ------------ | ---------------------------------------- |
| `tmpfs-size` | Size in bytes (accepts k, m, g suffixes) |
| `tmpfs-mode` | File mode (similar to chmod)             |

### Example: Secure Secret Handling

```bash
# Run app with secrets in tmpfs (never touches disk)
docker run -d \
    --name secure-app \
    --mount type=tmpfs,target=/run/secrets,tmpfs-size=1m \
    -e SECRET_FILE=/run/secrets/api-key \
    my-app

# Inject secret from environment (stays in memory)
docker exec secure-app sh -c 'echo "$API_KEY" > /run/secrets/api-key'
```

## Volume Drivers

Volume drivers allow storing data on remote hosts or cloud providers.

### Available Drivers

| Driver      | Description                         |
| ----------- | ----------------------------------- |
| `local`     | Default, stores on local filesystem |
| `nfs`       | Network File System                 |
| `azure`     | Azure File Storage                  |
| `aws`       | AWS EBS/EFS                         |
| Third-party | Many plugins available              |

### Using Local Driver with Options

```bash
# Create NFS volume
docker volume create \
    --driver local \
    --opt type=nfs \
    --opt o=addr=192.168.1.100,rw \
    --opt device=:/path/to/share \
    nfs-data

# Create volume with specific filesystem options
docker volume create \
    --driver local \
    --opt type=none \
    --opt device=/mnt/data \
    --opt o=bind \
    my-local-data
```

## Backup and Restore

### Backup a Volume

```bash
# Create a backup of volume data
docker run --rm \
    -v mysql-data:/source:ro \
    -v $(pwd):/backup \
    alpine \
    tar czf /backup/mysql-backup.tar.gz -C /source .

# Explanation:
# - Mount the volume as /source (read-only)
# - Mount current directory as /backup
# - Create tar.gz of all data in /source
```

### Restore a Volume

```bash
# Create new volume (if needed)
docker volume create mysql-data-restored

# Restore from backup
docker run --rm \
    -v mysql-data-restored:/target \
    -v $(pwd):/backup:ro \
    alpine \
    sh -c "cd /target && tar xzf /backup/mysql-backup.tar.gz"
```

### Copy Data Between Volumes

```bash
# Copy data from one volume to another
docker run --rm \
    -v source-volume:/source:ro \
    -v dest-volume:/dest \
    alpine \
    sh -c "cp -a /source/. /dest/"
```

### Automated Backup Script

See `examples/backup-restore/backup.sh` for a complete backup solution.

### Safe approach

```bash
docker pause my_container
# backup here
docker unpause my_container
```

## Best Practices

### 1. Use Volumes for Persistent Data

```bash
# ✅ Good - Named volume
docker run -d -v postgres-data:/var/lib/postgresql/data postgres

# ❌ Avoid - Anonymous volume (hard to manage)
docker run -d -v /var/lib/postgresql/data postgres
```

### 2. Use Bind Mounts for Development Only

```bash
# ✅ Development - bind mount for live reload
docker run -d -v $(pwd):/app -p 3000:3000 node npm run dev

# ✅ Production - built into image
docker run -d -p 3000:3000 my-app:production
```

### 3. Make Volumes Read-Only When Possible

```bash
# ✅ Config files should be read-only
docker run -d -v ./config:/app/config:ro my-app

# ✅ Only make writable what needs to be
docker run -d \
    -v config:/app/config:ro \
    -v data:/app/data \
    my-app
```

### 4. Use tmpfs for Sensitive Data

```bash
# ✅ Secrets never touch disk
docker run -d --tmpfs /run/secrets:size=1m my-app
```

### 5. Name Your Volumes Descriptively

```bash
# ✅ Good naming
docker volume create myapp-postgres-data
docker volume create myapp-uploads
docker volume create myapp-logs

# ❌ Bad naming
docker volume create data1
docker volume create vol
```

### 6. Clean Up Unused Volumes

```bash
# Remove unused volumes
docker volume prune

# See what's using space
docker system df -v
```

## Exercises

### 🎯 Exercise 1: Volume Basics

Practice creating and using volumes:

1. Create a named volume
2. Run a container with the volume
3. Write data to the volume
4. Stop and remove the container
5. Start a new container with the same volume
6. Verify the data persists

<details>
<summary>💡 Solution</summary>

```bash
# Create a volume
docker volume create test-data

# Run container and write data
docker run --rm \
    -v test-data:/data \
    alpine \
    sh -c "echo 'Hello, Volumes!' > /data/message.txt"

# Verify data persists in new container
docker run --rm \
    -v test-data:/data \
    alpine \
    cat /data/message.txt
# Output: Hello, Volumes!

# Inspect volume
docker volume inspect test-data

# Clean up
docker volume rm test-data
```

</details>

### 🎯 Exercise 2: Database Persistence

Set up a persistent MariaDB database:

1. Create a volume for MariaDB data
2. Run MariaDB with the volume
3. Create a database and table
4. Insert some data
5. Remove the container
6. Start a new container
7. Verify your data is still there

<details>
<summary>💡 Solution</summary>

```bash
# Create volume
docker volume create mariadb-data

# Run MariaDB
docker run -d \
    --name db \
    -v mariadb-data:/var/lib/mysql \
    -e MARIADB_ROOT_PASSWORD=secret \
    -e MARIADB_DATABASE=testdb \
    mariadb:latest

# Wait for MariaDB to start
sleep 30

# Create table and insert data
docker exec -i db mariadb -uroot -psecret testdb << 'EOF'
CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(100));
INSERT INTO users VALUES (1, 'Alice'), (2, 'Bob');
SELECT * FROM users;
EOF

# Remove container
docker rm -f db

# Start new container with same volume
docker run -d \
    --name db2 \
    -v mariadb-data:/var/lib/mysql \
    -e MARIADB_ROOT_PASSWORD=secret \
    mariadb:latest

# Wait for startup
sleep 20

# Verify data persists
docker exec db2 mariadb -uroot -psecret testdb -e "SELECT * FROM users;"

# Clean up
docker rm -f db2
docker volume rm mariadb-data
```

</details>

### 🎯 Exercise 3: Bind Mounts for Development

Set up a development environment with live code reload:

<details>
<summary>💡 Solution</summary>

```bash
# Create project directory
mkdir dev-mount-test && cd dev-mount-test

# Create a simple web page
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Dev Test</title></head>
<body>
    <h1>Hello from Bind Mount!</h1>
    <p>Edit this file and refresh - changes appear instantly!</p>
</body>
</html>
EOF

# Run nginx with bind mount
docker run -d \
    --name dev-web \
    -p 8080:80 \
    -v $(pwd):/usr/share/nginx/html:ro \
    nginx:alpine

# View in browser
curl http://localhost:8080

# Modify the file
echo "<p>This line was added live!</p>" >> index.html

# Refresh and see changes immediately
curl http://localhost:8080

# Clean up
docker rm -f dev-web
cd ..
rm -rf dev-mount-test
```

</details>

### 🎯 Exercise 4: Volume Backup and Restore

Practice backing up and restoring volume data:

<details>
<summary>💡 Solution</summary>

```bash
# Create and populate a volume
docker volume create important-data

docker run --rm \
    -v important-data:/data \
    alpine \
    sh -c "echo 'Critical data!' > /data/important.txt && date > /data/timestamp.txt"

# Create backup
docker run --rm \
    -v important-data:/source:ro \
    -v $(pwd):/backup \
    alpine \
    tar czf /backup/important-data-backup.tar.gz -C /source .

# Verify backup file exists
ls -la important-data-backup.tar.gz

# Simulate disaster - remove volume
docker volume rm important-data

# Restore from backup
docker volume create important-data-restored

docker run --rm \
    -v important-data-restored:/target \
    -v $(pwd):/backup:ro \
    alpine \
    sh -c "cd /target && tar xzf /backup/important-data-backup.tar.gz"

# Verify restoration
docker run --rm \
    -v important-data-restored:/data \
    alpine \
    cat /data/important.txt /data/timestamp.txt

# Clean up
docker volume rm important-data-restored
rm important-data-backup.tar.gz
```

</details>

### 🎯 Exercise 5: Sharing Volumes Between Containers

Share data between multiple containers:

<details>
<summary>💡 Solution</summary>

```bash
# Create shared volume
docker volume create shared-data

# Container 1: Writer - produces data
docker run -d \
    --name writer \
    -v shared-data:/data \
    alpine \
    sh -c "while true; do date >> /data/log.txt; sleep 5; done"

# Container 2: Reader - consumes data
docker run -d \
    --name reader \
    -v shared-data:/data:ro \
    alpine \
    sh -c "while true; do echo '--- Latest entries ---'; tail -3 /data/log.txt; sleep 5; done"

# View reader's output
docker logs reader
sleep 10
docker logs reader

# Both containers sharing the same volume!

# Clean up
docker rm -f writer reader
docker volume rm shared-data
```

</details>

### 🎯 Exercise 6: tmpfs for Sensitive Data

Practice using tmpfs for secrets:

<details>
<summary>💡 Solution</summary>

```bash
# Run container with tmpfs for secrets
docker run -d \
    --name secure-app \
    --mount type=tmpfs,target=/run/secrets,tmpfs-size=1m \
    alpine \
    sleep 3600

# Write a "secret" to tmpfs
docker exec secure-app sh -c 'echo "super-secret-password" > /run/secrets/password'

# Verify secret exists
docker exec secure-app cat /run/secrets/password

# Verify it's in memory (not on disk)
docker inspect secure-app --format='{{json .Mounts}}' | jq

# Stop container - secret is gone forever
docker rm -f secure-app

# If we tried to recover the secret, it's impossible - it was only in RAM
echo "Secret is permanently gone - never touched disk!"
```

</details>

## 📁 Examples Directory

```text
examples/
├── backup-restore/
│   ├── backup.sh
│   ├── restore.sh
│   └── README.md
├── development-workflow/
│   ├── docker-compose.yml
│   └── README.md
├── database-persistence/
│   ├── docker-compose.yml
│   ├── init/
│   │   └── 01-schema.sql
│   └── README.md
└── shared-volumes/
    ├── docker-compose.yml
    └── README.md
```

## 📝 Quick Reference

| Command                        | Description           |
| ------------------------------ | --------------------- |
| `docker volume create <name>`  | Create a volume       |
| `docker volume ls`             | List volumes          |
| `docker volume inspect <name>` | Volume details        |
| `docker volume rm <name>`      | Remove a volume       |
| `docker volume prune`          | Remove unused volumes |
| `-v name:/path`                | Mount named volume    |
| `-v /host:/container`          | Bind mount            |
| `--mount type=volume,...`      | Verbose volume mount  |
| `--mount type=bind,...`        | Verbose bind mount    |
| `--mount type=tmpfs,...`       | Memory-only mount     |
| `--tmpfs /path`                | Quick tmpfs mount     |

## ✅ Checklist

Before moving to the next section, make sure you can:

- [ ] Explain the difference between volumes, bind mounts, and tmpfs
- [ ] Create and manage Docker volumes
- [ ] Use volumes for database persistence
- [ ] Set up bind mounts for development
- [ ] Use tmpfs for sensitive temporary data
- [ ] Backup and restore volume data
- [ ] Share volumes between containers
- [ ] Use volumes in Docker Compose

⬅️ **Previous:** [Docker Networking](../05-networking-with-docker/README.md)

➡️ **Next:** [Docker Compose](../07-docker-compose/README.md)
